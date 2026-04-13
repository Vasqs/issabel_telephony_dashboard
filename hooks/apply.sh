#!/bin/bash
# Este hook roda automaticamente ao executar ./scripts/sync-workspace.sh
echo "[telephony_dashboard] Registrando Menu e ACL no SQLite interno do Issabel..."

# 1. Registrar no Menu (Aba PBX)
sqlite3 /var/www/db/menu.db "INSERT OR IGNORE INTO menu (id, IdParent, Link, Name, Type, order_no) VALUES ('telephony_dashboard', 'pbxconfig', '', 'Telephony Dash', 'module', 99);"

# 2. Registrar o Recurso no ACL
sqlite3 /var/www/db/acl.db "INSERT INTO acl_resource (name, description) SELECT 'telephony_dashboard', 'Telephony Dashboard' WHERE NOT EXISTS(SELECT 1 FROM acl_resource WHERE name='telephony_dashboard');"

# 3. Dar Permissão ao Grupo Administrador (id_group = 1)
sqlite3 /var/www/db/acl.db "INSERT INTO acl_group_permission (id_action, id_group, id_resource) SELECT 1, 1, id FROM acl_resource WHERE name='telephony_dashboard' AND NOT EXISTS(SELECT 1 FROM acl_group_permission p JOIN acl_resource r ON p.id_resource=r.id WHERE r.name='telephony_dashboard' AND p.id_group=1);"

echo "[telephony_dashboard] Registro concluído."
