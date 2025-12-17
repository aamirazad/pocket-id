set -eu
cd backend
mkdir -p .bin

# Check for --docker-only flag
DOCKER_ONLY=false
for arg in "$@"; do
    if [ "$arg" = "--docker-only" ]; then
        DOCKER_ONLY=true
        break
    fi
done

# Function to build for a specific platform
build_platform() {
    target=$1
    os=$2
    arch=$3
    arm_version=${4:-""}
    # "sed" is used to remove leading or trailing whitespace characters
    pocket_id_version=$(cat ../.version | sed 's/^\s*\|\s*$//g')

    # Set the binary extension to exe for Windows
    binary_ext=""
    if [ "$os" = "windows" ]; then
        binary_ext=".exe"
    fi

    output_dir=".bin/pocket-id-${target}${binary_ext}"

    printf "Building %s/%s%s" "$os" "$arch" "$([ -n "$arm_version" ] && echo " GOARM=$arm_version" || echo "")... "

    # Build environment variables
    env_vars="CGO_ENABLED=0 GOOS=${os} GOARCH=${arch}"
    if [ -n "$arm_version" ]; then
        env_vars="${env_vars} GOARM=${arm_version}"
    fi

    # Build the binary
    eval "${env_vars} go build \
        -ldflags='-X github.com/pocket-id/pocket-id/backend/internal/common.Version=${pocket_id_version} -buildid ${pocket_id_version} -s' \
        -o \"${output_dir}\" \
        -trimpath \
        ./cmd"

    printf "Done\n"
}

if [ "$DOCKER_ONLY" = true ]; then
    echo "Building for Docker platforms only (arm64 and amd64)..."
    build_platform "linux-amd64" "linux" "amd64" ""
    build_platform "linux-arm64" "linux" "arm64" ""
else
    echo "Building..."
    build_platform "linux-amd64" "linux" "amd64" ""

    build_platform "linux-arm64" "linux" "arm64" ""

fi

echo "Compilation done"
