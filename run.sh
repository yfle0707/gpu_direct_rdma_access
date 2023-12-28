make DEBUG_LOG=1 DEBUG_LOG_FAST_PATH=1
./server -a 30.1.5.1  -n 10000 -D 1 -s 8388608 -p 18001
./client -t 0 -a 30.1.5.2 30.1.5.1 -u 0e:00.0 -n 10000 -D 2 -s 8388608 -p 18001



./server -a 30.1.5.1  -n 100000 -D 1 -s 4194304 -p 18001
./client -t 0 -a 30.1.5.2 30.1.5.1 -u 0e:00.0 -n 100000 -D 0 -s 4194304 -p 18001
