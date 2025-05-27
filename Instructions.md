# Build all

make

# Build only cow.out

make cow

# Build only nofork.out

make nofork

# Build only p.out

make p

# Clean all .out files

make clean

---

# Build

docker build -t c-process-demo .

# Run interactively

docker run --rm -it c-process-demo


> cow run
> show cow-heap
> cow close
> exit
