#!/bin/bash
set -e
echo "===== Open edX Full Restore ====="
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TUTOR_ROOT="${TUTOR_ROOT:-/root/.local/share/tutor}"

echo "[1/8] Checking prerequisites..."
command -v tutor >/dev/null 2>&1 || { echo "ERROR: tutor not installed"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "ERROR: docker not installed"; exit 1; }

echo "[2/8] Restoring Tutor config..."
mkdir -p "$TUTOR_ROOT"
cp "$SCRIPT_DIR/tutor-env/config-full.yml" "$TUTOR_ROOT/config.yml"

echo "[3/8] Rendering Tutor environment..."
tutor config save

echo "[4/8] Starting services..."
tutor local start -d
echo "Waiting 30s for services..."
sleep 30

echo "[5/8] Restoring MySQL..."
MYSQL_CONTAINER=$(docker ps --format '{{.Names}}' | grep mysql | head -1)
MYSQL_ROOT_PASS=$(grep MYSQL_ROOT_PASSWORD "$TUTOR_ROOT/config.yml" | awk '{print $2}')
docker exec -i $MYSQL_CONTAINER mysql -u root -p"$MYSQL_ROOT_PASS" < "$SCRIPT_DIR/database/mysql-full-dump.sql"

echo "[6/8] Restoring MongoDB..."
MONGO_CONTAINER=$(docker ps --format '{{.Names}}' | grep mongodb | head -1)
docker cp "$SCRIPT_DIR/database/mongo-dump.archive.gz" $MONGO_CONTAINER:/tmp/mongo-dump.archive.gz
docker exec $MONGO_CONTAINER mongorestore --archive=/tmp/mongo-dump.archive.gz --gzip --drop

echo "[7/8] Restoring omnix theme..."
LMS_CONTAINER=$(docker ps --format '{{.Names}}' | grep lms | grep -v worker | head -1)
CMS_CONTAINER=$(docker ps --format '{{.Names}}' | grep cms | grep -v worker | head -1)
docker cp "$SCRIPT_DIR/themes/omnix/" $LMS_CONTAINER:/openedx/themes/omnix/
docker cp "$SCRIPT_DIR/themes/staticfiles-omnix/omnix/" $LMS_CONTAINER:/openedx/staticfiles/omnix/
docker cp "$SCRIPT_DIR/themes/staticfiles-omnix/omnix/" $CMS_CONTAINER:/openedx/staticfiles/omnix/
cp -r "$SCRIPT_DIR/tutor-env/themes/"* "$TUTOR_ROOT/env/build/openedx/themes/" 2>/dev/null || true
docker exec -u 0 $LMS_CONTAINER chown -R app:app /openedx/themes/omnix /openedx/staticfiles/omnix
docker exec -u 0 $CMS_CONTAINER chown -R app:app /openedx/staticfiles/omnix 2>/dev/null || true
docker exec $LMS_CONTAINER python -c "import shutil; shutil.rmtree('/tmp/mako_lms', True); shutil.rmtree('/openedx/data/lms/mako_templates', True)"

echo "[8/8] Restarting..."
docker restart $LMS_CONTAINER $CMS_CONTAINER
echo "===== Restore complete! ====="
