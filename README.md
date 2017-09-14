# Beethoven

>docker build -t beethoven-test . 
#
>docker run -p "8000:80" -e REDIS_MASTER_ADDRESS=10.200.10.1 -e REDIS_MASTER_PORT=6379 -e REDIS_MASTER_PASSWORD=1234 beethoven-test 