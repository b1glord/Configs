# 📄 Dosya Yolu: /NopCommerce/current/installer/tools/docker_stack_tool.sh
# 📌 Amac: nopCommerce uygulama, Nginx ve opsiyonel DB servislerini Docker Compose ile yonetmek
# 📌 Modul - Shell
# Version: 1.1.1
# Aciklama: Resmi NoSource release'i surume uygun ASP.NET runtime image ile paketler ve tam Compose stack olusturur
# Bagimli Oldugu Katman: Config | Repo | View | Language

set -Eeuo pipefail

docker_stack_tool_escape_sed() {
    printf '%s' "$1" | sed 's/[&|]/\\&/g'
}

docker_stack_tool_validate_service_name() {
    local label="$1"
    local value="$2"

    if ! [[ "${value}" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
        console_view_error "${ERR_DOCKER_STACK_SERVICE_NAME}: ${label}"
        return 64
    fi
}

docker_stack_tool_validate_port() {
    local value="$1"

    [[ "${value}" =~ ^[0-9]+$ ]] && (( value >= 1 && value <= 65535 ))
}

docker_stack_tool_validate_config() {
    if ! [[ "${NOP_DOCKER_STACK_PROJECT}" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
        console_view_error "${ERR_DOCKER_STACK_PROJECT}"
        return 64
    fi

    docker_stack_tool_validate_service_name "NOP_DOCKER_STACK_APP_SERVICE" "${NOP_DOCKER_STACK_APP_SERVICE}"
    docker_stack_tool_validate_service_name "NOP_DOCKER_STACK_DATABASE_SERVICE" "${NOP_DOCKER_STACK_DATABASE_SERVICE}"
    docker_stack_tool_validate_service_name "NOP_DOCKER_STACK_NGINX_SERVICE" "${NOP_DOCKER_STACK_NGINX_SERVICE}"

    if ! docker_stack_tool_validate_port "${NOP_DOCKER_STACK_APP_PORT}" ||        ! docker_stack_tool_validate_port "${NOP_DOCKER_STACK_HTTP_PORT}"; then
        console_view_error "${ERR_DOCKER_STACK_PORT}"
        return 64
    fi
}

docker_stack_tool_require_docker() {
    if ! command -v "${NOP_DOCKER_EXECUTABLE}" >/dev/null 2>&1; then
        console_view_error "${ERR_DOCKER_NOT_FOUND}: ${NOP_DOCKER_EXECUTABLE}"
        return 69
    fi

    if ! "${NOP_DOCKER_EXECUTABLE}" info >/dev/null 2>&1; then
        console_view_error "${ERR_DOCKER_DAEMON}"
        return 69
    fi

    if ! "${NOP_DOCKER_EXECUTABLE}" compose version >/dev/null 2>&1; then
        console_view_error "${ERR_DOCKER_COMPOSE}"
        return 69
    fi
}

docker_stack_tool_validate_public_port() {
    local existing_container

    existing_container="$("${NOP_DOCKER_EXECUTABLE}" ps -q         --filter "label=com.docker.compose.project=${NOP_DOCKER_STACK_PROJECT}"         --filter "label=com.docker.compose.service=${NOP_DOCKER_STACK_NGINX_SERVICE}"         | head -n 1)"

    if [[ -n "${existing_container}" ]]; then
        return 0
    fi

    if command -v ss >/dev/null 2>&1 &&        ss -ltnH 2>/dev/null | awk -v port=":${NOP_DOCKER_STACK_HTTP_PORT}" '$4 ~ (port "$") { found=1 } END { exit !found }'; then
        console_view_error "${ERR_DOCKER_STACK_PORT_BUSY}: ${NOP_DOCKER_STACK_HTTP_PORT}"
        return 98
    fi
}

docker_stack_tool_release_dir() {
    printf '%s/%s' "${NOP_RELEASES_DIR}" "${NOP_VERSION}"
}

docker_stack_tool_dockerfile_path() {
    printf '%s/%s' "$(docker_stack_tool_release_dir)" "${NOP_DOCKER_STACK_DOCKERFILE_RELATIVE}"
}

docker_stack_tool_dockerignore_path() {
    printf '%s/%s' "$(docker_stack_tool_release_dir)" "${NOP_DOCKER_STACK_DOCKERIGNORE_RELATIVE}"
}

docker_stack_tool_write_runtime_packages() {
    local dockerfile="$1"

    case "${NOP_DOCKER_APP_RUNTIME_PROFILE}" in
        legacy31|legacy50)
            cat >> "${dockerfile}" <<'EOF'
RUN apk add --no-cache icu-libs \
    && apk add libgdiplus --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
    && apk add libc-dev --no-cache
EOF
            ;;
        runtime60)
            cat >> "${dockerfile}" <<'EOF'
RUN apk add --no-cache icu-libs \
    && apk add libgdiplus --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
    && apk add libc-dev tzdata --no-cache \
    && ln -sf /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2
EOF
            ;;
        runtime70)
            cat >> "${dockerfile}" <<'EOF'
RUN apk add --no-cache icu-libs \
    && apk add tiff --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted \
    && apk add libgdiplus --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
    && apk add libc-dev tzdata --no-cache \
    && ln -sf /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2
EOF
            ;;
        runtime80|runtime90)
            cat >> "${dockerfile}" <<'EOF'
RUN apk add --no-cache icu-libs icu-data-full \
    && apk add tiff --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted \
    && apk add libgdiplus --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
    && apk add libc-dev tzdata --no-cache \
    && ln -sf /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2
EOF
            ;;
        runtime90gcompat)
            cat >> "${dockerfile}" <<'EOF'
RUN apk add --no-cache icu-libs icu-data-full \
    && apk add tiff --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted \
    && apk add libgdiplus --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
    && apk add libc-dev tzdata gcompat --no-cache
EOF
            ;;
        runtime100)
            cat >> "${dockerfile}" <<'EOF'
RUN apk add --no-cache icu-libs icu-data-full \
    && apk add tiff --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/main/ --allow-untrusted \
    && apk add libgdiplus --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
    && apk add libc-dev tzdata gcompat --no-cache
EOF
            ;;
        *)
            console_view_error "${ERR_APP_DOCKER_RUNTIME}: ${NOP_DOCKER_APP_RUNTIME_PROFILE}"
            return 65
            ;;
    esac
}

docker_stack_tool_write_dockerfile() {
    local dockerfile
    local dockerfile_dir
    local dockerignore

    dockerfile="$(docker_stack_tool_dockerfile_path)"
    dockerfile_dir="$(dirname "${dockerfile}")"
    dockerignore="$(docker_stack_tool_dockerignore_path)"

    mkdir -p "${dockerfile_dir}"

    cat > "${dockerfile}" <<EOF
# 📄 Dosya Yolu: ${NOP_DOCKER_STACK_DOCKERFILE_RELATIVE}
# 📌 Amac: nopCommerce ${NOP_VERSION} NoSource release paketini Docker runtime image icinde calistirmak
# 📌 Modul - Dockerfile
# Version: 1.0.0
# Aciklama: Installer tarafindan surume gore uretilen runtime-only nopCommerce image tanimi
# Bagimli Oldugu Katman: Tool | Config

FROM ${NOP_DOCKER_APP_RUNTIME_IMAGE}

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
EOF

    docker_stack_tool_write_runtime_packages "${dockerfile}"

    cat >> "${dockerfile}" <<EOF

WORKDIR /app

COPY . /app

RUN mkdir -p \
    App_Data \
    App_Data/DataProtectionKeys \
    bin \
    logs \
    Plugins \
    wwwroot/bundles \
    wwwroot/db_backups \
    wwwroot/files/exportimport \
    wwwroot/icons \
    wwwroot/images \
    wwwroot/images/thumbs \
    wwwroot/images/uploaded \
    wwwroot/sitemaps

ENV ASPNETCORE_URLS=http://+:${NOP_DOCKER_STACK_APP_PORT}

EXPOSE ${NOP_DOCKER_STACK_APP_PORT}

ENTRYPOINT ["dotnet", "Nop.Web.dll"]
EOF

    if [[ ! -f "${dockerignore}" ]]; then
        printf '%s\n' "${NOP_DOCKER_STACK_DOCKERFILE_RELATIVE%%/*}" > "${dockerignore}"
    elif ! grep -qxF "${NOP_DOCKER_STACK_DOCKERFILE_RELATIVE%%/*}" "${dockerignore}"; then
        printf '%s\n' "${NOP_DOCKER_STACK_DOCKERFILE_RELATIVE%%/*}" >> "${dockerignore}"
    fi
}

docker_stack_tool_seed_persistent_path() {
    local relative_path="$1"
    local source_path
    local target_path

    source_path="${NOP_CURRENT_DIR}/${relative_path}"
    target_path="${NOP_DOCKER_STACK_PERSIST_ROOT}/${relative_path}"

    if [[ -d "${target_path}" ]]; then
        return 0
    fi

    mkdir -p "${target_path}"

    if [[ -d "${source_path}" ]]; then
        cp -a "${source_path}/." "${target_path}/"
    fi
}

docker_stack_tool_prepare_persistent_data() {
    local relative_path
    local paths

    mkdir -p "${NOP_DOCKER_STACK_ROOT}" "${NOP_DOCKER_STACK_PERSIST_ROOT}"
    chmod 700 "${NOP_DOCKER_STACK_ROOT}"

    IFS=':' read -r -a paths <<< "${NOP_DOCKER_STACK_PERSIST_PATHS}"

    for relative_path in "${paths[@]}"; do
        docker_stack_tool_seed_persistent_path "${relative_path}"
    done
}

docker_stack_tool_write_nginx_config() {
    local template_path
    local public_host
    local app_service
    local app_port

    template_path="${INSTALLER_ROOT}/config/docker/nginx.conf.tpl"
    public_host="$(docker_stack_tool_escape_sed "${NOP_PUBLIC_HOST}")"
    app_service="$(docker_stack_tool_escape_sed "${NOP_DOCKER_STACK_APP_SERVICE}")"
    app_port="$(docker_stack_tool_escape_sed "${NOP_DOCKER_STACK_APP_PORT}")"

    sed         -e "s|__PUBLIC_HOST__|${public_host}|g"         -e "s|__APP_SERVICE__|${app_service}|g"         -e "s|__APP_PORT__|${app_port}|g"         "${template_path}" > "${NOP_DOCKER_STACK_NGINX_CONFIG}"
}

docker_stack_tool_write_app_service() {
    local compose_file="$1"
    local relative_path
    local paths
    local release_dir

    release_dir="$(docker_stack_tool_release_dir)"

    cat >> "${compose_file}" <<EOF
  ${NOP_DOCKER_STACK_APP_SERVICE}:
    build:
      context: "${release_dir}"
      dockerfile: "${NOP_DOCKER_STACK_DOCKERFILE_RELATIVE}"
    image: "${NOP_DOCKER_STACK_APP_IMAGE}:${NOP_VERSION}"
    restart: unless-stopped
    environment:
      ASPNETCORE_URLS: "http://+:${NOP_DOCKER_STACK_APP_PORT}"
    expose:
      - "${NOP_DOCKER_STACK_APP_PORT}"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    volumes:
EOF

    IFS=':' read -r -a paths <<< "${NOP_DOCKER_STACK_PERSIST_PATHS}"

    for relative_path in "${paths[@]}"; do
        printf '      - "%s/%s:/app/%s"\n'             "${NOP_DOCKER_STACK_PERSIST_ROOT}"             "${relative_path}"             "${relative_path}" >> "${compose_file}"
    done

    if [[ "${NOP_DB_MODE_RESOLVED}" == "docker" ]]; then
        cat >> "${compose_file}" <<EOF
    depends_on:
      ${NOP_DOCKER_STACK_DATABASE_SERVICE}:
        condition: service_healthy
EOF
    fi
}

docker_stack_tool_write_mysql_service() {
    local compose_file="$1"

    {
        printf '  %s:\n' "${NOP_DOCKER_STACK_DATABASE_SERVICE}"
        printf '    image: "%s"\n' "${NOP_DB_DOCKER_MYSQL_IMAGE}"
        printf '%s\n' '    restart: unless-stopped'
        printf '%s\n' '    environment:'
        printf '%s\n' '      MYSQL_ROOT_PASSWORD: "${NOP_DB_ROOT_PASSWORD}"'
        printf '%s\n' '      MYSQL_DATABASE: "${NOP_DB_NAME}"'
        printf '%s\n' '      MYSQL_USER: "${NOP_DB_USER}"'
        printf '%s\n' '      MYSQL_PASSWORD: "${NOP_DB_PASSWORD}"'
        printf '%s\n' '    volumes:'
        printf '%s\n' '      - database-data:/var/lib/mysql'
        printf '%s\n' '    healthcheck:'
        printf '%s\n' '      test:'
        printf '%s\n' '        - CMD-SHELL'
        printf '%s\n' '        - '\''MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --host 127.0.0.1 --user root --batch --skip-column-names --execute "SELECT 1"'\'''
        printf '%s\n' '      interval: 5s'
        printf '%s\n' '      timeout: 5s'
        printf '%s\n' '      retries: 24'
    } >> "${compose_file}"
}

docker_stack_tool_write_postgresql_service() {
    local compose_file="$1"

    {
        printf '  %s:\n' "${NOP_DOCKER_STACK_DATABASE_SERVICE}"
        printf '    image: "%s"\n' "${NOP_DB_DOCKER_POSTGRESQL_IMAGE}"
        printf '%s\n' '    restart: unless-stopped'
        printf '%s\n' '    environment:'
        printf '%s\n' '      POSTGRES_DB: "${NOP_DB_NAME}"'
        printf '%s\n' '      POSTGRES_USER: "${NOP_DB_USER}"'
        printf '%s\n' '      POSTGRES_PASSWORD: "${NOP_DB_PASSWORD}"'
        printf '%s\n' '    volumes:'
        printf '%s\n' '      - database-data:/var/lib/postgresql/data'
        printf '%s\n' '    healthcheck:'
        printf '%s\n' '      test:'
        printf '%s\n' '        - CMD-SHELL'
        printf '%s\n' '        - '\''PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" --tuples-only --command "SELECT 1"'\'''
        printf '%s\n' '      interval: 5s'
        printf '%s\n' '      timeout: 5s'
        printf '%s\n' '      retries: 24'
    } >> "${compose_file}"
}

docker_stack_tool_write_database_service() {
    local compose_file="$1"

    if [[ "${NOP_DB_MODE_RESOLVED}" != "docker" ]]; then
        return 0
    fi

    case "${NOP_DB_PROVIDER_OFFICIAL}" in
        MySql)
            docker_stack_tool_write_mysql_service "${compose_file}"
            ;;
        PostgreSQL)
            docker_stack_tool_write_postgresql_service "${compose_file}"
            ;;
        *)
            console_view_error "${ERR_DB_DOCKER_PROVIDER}: ${NOP_DB_PROVIDER_OFFICIAL}"
            return 65
            ;;
    esac
}

docker_stack_tool_write_nginx_service() {
    local compose_file="$1"

    cat >> "${compose_file}" <<EOF
  ${NOP_DOCKER_STACK_NGINX_SERVICE}:
    image: "${NOP_DOCKER_STACK_NGINX_IMAGE}"
    restart: unless-stopped
    depends_on:
      - "${NOP_DOCKER_STACK_APP_SERVICE}"
    ports:
      - "${NOP_DOCKER_STACK_HTTP_BIND_HOST}:${NOP_DOCKER_STACK_HTTP_PORT}:80"
    volumes:
      - "${NOP_DOCKER_STACK_NGINX_CONFIG}:/etc/nginx/conf.d/default.conf:ro"
EOF
}

docker_stack_tool_write_compose() {
    local compose_file

    compose_file="${NOP_DOCKER_STACK_COMPOSE_FILE}"

    cat > "${compose_file}" <<EOF
# 📄 Dosya Yolu: ${NOP_DOCKER_STACK_COMPOSE_FILE}
# 📌 Amac: nopCommerce uygulama, Nginx ve opsiyonel veritabani servislerini birlikte calistirmak
# 📌 Modul - YAML
# Version: 1.0.0
# Aciklama: Installer tarafindan uretilen tam Docker Compose deployment tanimi
# Bagimli Oldugu Katman: Tool | Config

services:
EOF

    docker_stack_tool_write_app_service "${compose_file}"
    docker_stack_tool_write_database_service "${compose_file}"
    docker_stack_tool_write_nginx_service "${compose_file}"

    if [[ "${NOP_DB_MODE_RESOLVED}" == "docker" ]]; then
        cat >> "${compose_file}" <<'EOF'

volumes:
  database-data:
EOF
    fi
}

docker_stack_tool_validate_compose() {
    "${NOP_DOCKER_EXECUTABLE}" compose         -p "${NOP_DOCKER_STACK_PROJECT}"         -f "${NOP_DOCKER_STACK_COMPOSE_FILE}"         config -q
}

docker_stack_tool_up() {
    console_view_info "${MSG_DOCKER_STACK_UP}"

    "${NOP_DOCKER_EXECUTABLE}" compose         -p "${NOP_DOCKER_STACK_PROJECT}"         -f "${NOP_DOCKER_STACK_COMPOSE_FILE}"         up -d --build --remove-orphans

    "${NOP_DOCKER_EXECUTABLE}" compose         -p "${NOP_DOCKER_STACK_PROJECT}"         -f "${NOP_DOCKER_STACK_COMPOSE_FILE}"         ps
}

docker_stack_tool_install() {
    if [[ "${NOP_APP_MODE_RESOLVED}" != "docker" ]]; then
        return 0
    fi

    docker_stack_tool_validate_config
    docker_stack_tool_require_docker
    docker_stack_tool_validate_public_port
    docker_stack_tool_prepare_persistent_data
    docker_stack_tool_write_dockerfile
    docker_stack_tool_write_nginx_config
    docker_stack_tool_write_compose
    docker_stack_tool_validate_compose
    docker_stack_tool_up
}
