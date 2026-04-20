#!/bin/bash
# Este hook roda automaticamente ao executar ./scripts/sync-workspace.sh
echo "[telephony_dashboard] Registrando Menu e ACL no SQLite interno do Issabel..."

# 1. Registrar no Menu (Aba PBX)
if [ -f /var/www/db/menu.db ]; then
  sqlite3 /var/www/db/menu.db "DELETE FROM menu WHERE id='telephony_dashboard' AND rowid NOT IN (SELECT MIN(rowid) FROM menu WHERE id='telephony_dashboard');"
  sqlite3 /var/www/db/menu.db "INSERT INTO menu (id, IdParent, Link, Name, Type, order_no) SELECT 'telephony_dashboard', 'pbxconfig', '', 'Telephony Dash', 'module', 99 WHERE NOT EXISTS(SELECT 1 FROM menu WHERE id='telephony_dashboard');"
fi

# 2. Registrar o Recurso no ACL
if [ -f /var/www/db/acl.db ]; then
  sqlite3 /var/www/db/acl.db "INSERT INTO acl_resource (name, description) SELECT 'telephony_dashboard', 'Telephony Dashboard' WHERE NOT EXISTS(SELECT 1 FROM acl_resource WHERE name='telephony_dashboard');"

# 3. Dar Permissão ao Grupo Administrador (id_group = 1)
  sqlite3 /var/www/db/acl.db "INSERT INTO acl_group_permission (id_action, id_group, id_resource) SELECT 1, 1, id FROM acl_resource WHERE name='telephony_dashboard' AND NOT EXISTS(SELECT 1 FROM acl_group_permission p JOIN acl_resource r ON p.id_resource=r.id WHERE r.name='telephony_dashboard' AND p.id_group=1);"
fi

echo "[telephony_dashboard] Registro concluído."
