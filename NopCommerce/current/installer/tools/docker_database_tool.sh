# 📄 Dosya Yolu: /NopCommerce/current/installer/tools/docker_database_tool.sh
# 📌 Amac: MySQL ve PostgreSQL veritabani containerlarini kalici volume ile provision etmek
# 📌 Modul - Shell
# Version: 1.1.1
# Aciklama: Loopback bind, guvenli env-file, config drift kontrolu, lifecycle ve kimlik dogrulamali readiness adaptoru
# Bagimli Oldugu Katman: Config | View | Language

set -Eeuo pipefail

docker_database_tool_require_docker() {
    if ! command -v "${NOP_DOCKER_EXECUTABLE}" >/dev/null 2>&1; then
        console_view_error "${ERR_DOCKER_NOT_FOUND}: ${NOP_DOCKER_EXECUTABLE}"
        return 69
    fi

    if ! "${NOP_DOCKER_EXECUTABLE}" info >/dev/null 2>&1; then
        console_view_error "${ERR_DOCKER_DAEMON}"
        return 69
    fi
}

docker_database_tool_container_name() {
    case "${NOP_DB_PROVIDER_OFFICIAL}" in
        MySql)
            printf '%s-mysql' "${NOP_DB_DOCKER_CONTAINER_PREFIX}"
            ;;
        PostgreSQL)
            printf '%s-postgresql' "${NOP_DB_DOCKER_CONTAINER_PREFIX}"
            ;;
        *)
            return 65
            ;;
    esac
}

docker_database_tool_volume_name() {
    case "${NOP_DB_PROVIDER_OFFICIAL}" in
        MySql)
            printf '%s-mysql-data' "${NOP_DB_DOCKER_VOLUME_PREFIX}"
            ;;
        PostgreSQL)
            printf '%s-postgresql-data' "${NOP_DB_DOCKER_VOLUME_PREFIX}"
            ;;
        *)
            return 65
            ;;
    esac
}

docker_database_tool_image() {
    case "${NOP_DB_PROVIDER_OFFICIAL}" in
        MySql)
            printf '%s' "${NOP_DB_DOCKER_MYSQL_IMAGE}"
            ;;
        PostgreSQL)
            printf '%s' "${NOP_DB_DOCKER_POSTGRESQL_IMAGE}"
            ;;
        *)
            return 65
            ;;
    esac
}

docker_database_tool_host_port() {
    case "${NOP_DB_PROVIDER_OFFICIAL}" in
        MySql)
            printf '%s' "${NOP_DB_DOCKER_MYSQL_PORT}"
            ;;
        PostgreSQL)
            printf '%s' "${NOP_DB_DOCKER_POSTGRESQL_PORT}"
            ;;
        *)
            return 65
            ;;
    esac
}

docker_database_tool_config_fingerprint() {
    local image
    local port

    image="$(docker_database_tool_image)"
    port="$(docker_database_tool_host_port)"

    printf '%s' "${NOP_DB_PROVIDER_OFFICIAL}|${image}|${NOP_DB_NAME}|${NOP_DB_USER}|${NOP_DB_DOCKER_BIND_HOST}|${port}"         | sha256sum         | awk '{print $1}'
}

docker_database_tool_container_exists() {
    local container_name="$1"

    "${NOP_DOCKER_EXECUTABLE}" container inspect "${container_name}" >/dev/null 2>&1
}

docker_database_tool_container_running() {
    local container_name="$1"

    [[ "$("${NOP_DOCKER_EXECUTABLE}" inspect -f '{{.State.Running}}' "${container_name}" 2>/dev/null || true)" == "true" ]]
}

docker_database_tool_validate_existing_config() {
    local container_name="$1"
    local expected
    local actual

    expected="$(docker_database_tool_config_fingerprint)"
    actual="$("${NOP_DOCKER_EXECUTABLE}" inspect         -f '{{ index .Config.Labels "com.turkuaz.nopcommerce.db.config-sha" }}'         "${container_name}" 2>/dev/null || true)"

    if [[ -z "${actual}" || "${actual}" != "${expected}" ]]; then
        console_view_error "${ERR_DB_DOCKER_DRIFT}: ${container_name}"
        return 78
    fi
}

docker_database_tool_pull_image() {
    local image="$1"

    console_view_value "${MSG_DB_DOCKER_IMAGE}" "${image}"
    "${NOP_DOCKER_EXECUTABLE}" pull "${image}" >/dev/null
}

docker_database_tool_make_env_file() {
    local env_file

    mkdir -p "${NOP_TEMP_DIR}"
    chmod 700 "${NOP_TEMP_DIR}"

    env_file="$(mktemp "${NOP_TEMP_DIR}/docker-db-env.XXXXXX")"
    chmod 600 "${env_file}"

    case "${NOP_DB_PROVIDER_OFFICIAL}" in
        MySql)
            {
                printf 'MYSQL_ROOT_PASSWORD=%s\n' "${NOP_DB_ROOT_PASSWORD}"
                printf 'MYSQL_DATABASE=%s\n' "${NOP_DB_NAME}"
                printf 'MYSQL_USER=%s\n' "${NOP_DB_USER}"
                printf 'MYSQL_PASSWORD=%s\n' "${NOP_DB_PASSWORD}"
            } > "${env_file}"
            ;;
        PostgreSQL)
            {
                printf 'POSTGRES_DB=%s\n' "${NOP_DB_NAME}"
                printf 'POSTGRES_USER=%s\n' "${NOP_DB_USER}"
                printf 'POSTGRES_PASSWORD=%s\n' "${NOP_DB_PASSWORD}"
            } > "${env_file}"
            ;;
        *)
            rm -f "${env_file}"
            return 65
            ;;
    esac

    printf '%s' "${env_file}"
}

docker_database_tool_create_mysql() {
    local container_name="$1"
    local volume_name="$2"
    local env_file
    local fingerprint

    docker_database_tool_pull_image "${NOP_DB_DOCKER_MYSQL_IMAGE}"
    env_file="$(docker_database_tool_make_env_file)"
    fingerprint="$(docker_database_tool_config_fingerprint)"

    if ! "${NOP_DOCKER_EXECUTABLE}" run -d         --name "${container_name}"         --restart unless-stopped         --publish "${NOP_DB_DOCKER_BIND_HOST}:${NOP_DB_DOCKER_MYSQL_PORT}:3306"         --volume "${volume_name}:/var/lib/mysql"         --label "com.turkuaz.nopcommerce.db.managed=true"         --label "com.turkuaz.nopcommerce.db.config-sha=${fingerprint}"         --env-file "${env_file}"         "${NOP_DB_DOCKER_MYSQL_IMAGE}" >/dev/null; then
        rm -f "${env_file}"
        return 70
    fi

    rm -f "${env_file}"
}

docker_database_tool_create_postgresql() {
    local container_name="$1"
    local volume_name="$2"
    local env_file
    local fingerprint

    docker_database_tool_pull_image "${NOP_DB_DOCKER_POSTGRESQL_IMAGE}"
    env_file="$(docker_database_tool_make_env_file)"
    fingerprint="$(docker_database_tool_config_fingerprint)"

    if ! "${NOP_DOCKER_EXECUTABLE}" run -d         --name "${container_name}"         --restart unless-stopped         --publish "${NOP_DB_DOCKER_BIND_HOST}:${NOP_DB_DOCKER_POSTGRESQL_PORT}:5432"         --volume "${volume_name}:/var/lib/postgresql/data"         --label "com.turkuaz.nopcommerce.db.managed=true"         --label "com.turkuaz.nopcommerce.db.config-sha=${fingerprint}"         --env-file "${env_file}"         "${NOP_DB_DOCKER_POSTGRESQL_IMAGE}" >/dev/null; then
        rm -f "${env_file}"
        return 70
    fi

    rm -f "${env_file}"
}

docker_database_tool_create() {
    local container_name="$1"
    local volume_name="$2"

    console_view_value "${MSG_DB_DOCKER_CONTAINER}" "${container_name}"

    case "${NOP_DB_PROVIDER_OFFICIAL}" in
        MySql)
            docker_database_tool_create_mysql "${container_name}" "${volume_name}"
            ;;
        PostgreSQL)
            docker_database_tool_create_postgresql "${container_name}" "${volume_name}"
            ;;
        *)
            console_view_error "${ERR_DB_DOCKER_PROVIDER}: ${NOP_DB_PROVIDER_OFFICIAL}"
            return 65
            ;;
    esac
}

docker_database_tool_start_existing() {
    local container_name="$1"

    console_view_info "${MSG_DB_DOCKER_REUSE}"

    if docker_database_tool_container_running "${container_name}"; then
        return 0
    fi

    console_view_value "${MSG_DB_DOCKER_START}" "${container_name}"
    "${NOP_DOCKER_EXECUTABLE}" start "${container_name}" >/dev/null
}

docker_database_tool_ready_mysql() {
    local container_name="$1"

    "${NOP_DOCKER_EXECUTABLE}" exec         "${container_name}"         sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --host 127.0.0.1 --user root --batch --skip-column-names --execute "SELECT 1"'         >/dev/null 2>&1
}

docker_database_tool_ready_postgresql() {
    local container_name="$1"

    "${NOP_DOCKER_EXECUTABLE}" exec         "${container_name}"         sh -c 'PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" --tuples-only --command "SELECT 1"'         >/dev/null 2>&1
}

docker_database_tool_ready() {
    local container_name="$1"

    case "${NOP_DB_PROVIDER_OFFICIAL}" in
        MySql)
            docker_database_tool_ready_mysql "${container_name}"
            ;;
        PostgreSQL)
            docker_database_tool_ready_postgresql "${container_name}"
            ;;
        *)
            return 65
            ;;
    esac
}

docker_database_tool_wait_ready() {
    local container_name="$1"
    local elapsed=0

    console_view_info "${MSG_DB_DOCKER_WAIT}"

    while (( elapsed < NOP_DB_DOCKER_START_TIMEOUT )); do
        if docker_database_tool_ready "${container_name}"; then
            console_view_info "${MSG_DB_DOCKER_READY}"
            return 0
        fi

        sleep 2
        elapsed=$((elapsed + 2))
    done

    console_view_error "${ERR_DB_DOCKER_TIMEOUT}: ${container_name}"
    return 70
}

docker_database_tool_provision() {
    local container_name
    local volume_name

    if [[ "${NOP_DB_MODE_RESOLVED}" != "docker" ]]; then
        return 0
    fi

    docker_database_tool_require_docker

    container_name="$(docker_database_tool_container_name)"
    volume_name="$(docker_database_tool_volume_name)"

    if docker_database_tool_container_exists "${container_name}"; then
        docker_database_tool_validate_existing_config "${container_name}"
        docker_database_tool_start_existing "${container_name}"
    else
        docker_database_tool_create "${container_name}" "${volume_name}"
    fi

    docker_database_tool_wait_ready "${container_name}"
}
