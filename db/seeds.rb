# =============================================================================
# seeds.rb — обязательные данные для ВСЕХ окружений (roles)
# =============================================================================
# Запуск:  bin/rails db:seed
# Сброс:   bin/rails db:reset   (удаляет БД, заново мигрирует + сидит)
# =============================================================================

# --- Роли (нужны везде: dev, test, production) --------------------------------
%w[super_admin coordinator teacher student].each do |role_name|
  Role.find_or_create_by!(name: role_name)
end
puts "✅ #{Role.count} roles"

# --- Реалистичные тестовые данные (только development) -----------------------
if Rails.env.development?
  require_relative "seeds/development"
end
