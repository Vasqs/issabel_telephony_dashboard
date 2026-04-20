#!/bin/bash
# Este hook roda automaticamente ao executar ./scripts/sync-workspace.sh
echo "[telephony_dashboard] Registrando Menu e ACL no SQLite interno do Issabel..."

MODULE_CANONICAL_NAME="telephony_dashboard"

ensure_module_alias() {
  local actual_module_dir
  local actual_module_name
  local modules_parent_dir
  local alias_path
  local alias_target

  actual_module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  actual_module_name="$(basename "$actual_module_dir")"
  modules_parent_dir="$(dirname "$actual_module_dir")"
  alias_path="${modules_parent_dir}/${MODULE_CANONICAL_NAME}"

  if [ "$actual_module_name" = "$MODULE_CANONICAL_NAME" ]; then
    return 0
  fi

  if [ -L "$alias_path" ]; then
    alias_target="$(readlink "$alias_path" || true)"
    if [ "$alias_target" != "$actual_module_name" ]; then
      rm -f "$alias_path"
      ln -s "$actual_module_name" "$alias_path"
    fi
    return 0
  fi

  if [ ! -e "$alias_path" ]; then
    ln -s "$actual_module_name" "$alias_path"
  fi
}

ensure_module_alias

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
