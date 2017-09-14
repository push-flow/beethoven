# Configure timezone
if [ "$CONTAINER_TIMEZONE" ]; then
    echo ${CONTAINER_TIMEZONE} >/etc/timezone && \
    ln -sf /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
fi

mkdir /etc/redis
cp /home/config/redis-stable/redis.conf /etc/redis
echo "slaveof ${REDIS_MASTER_ADDRESS} ${REDIS_MASTER_PORT}" >> /etc/redis/redis.conf
echo "masterauth ${REDIS_MASTER_PASSWORD}" >> /etc/redis/redis.conf

supervisord -n