import java.util.concurrent.Semaphore;

Semaphore mutex1 = new Semaphore(1);
Semaphore mutex2 = new Semaphore(0);

int n2 = 0;
int n = 50;

Thread.start {
    while (n > 0) {
        mutex2.acquire();
        n = n - 1;
        mutex1.release();
    }
    print(n2);
}

Thread.start {
    while (true) {
        mutex1.acquire();
        n2 = n2 + 2*n + 1;
        mutex2.release();
    }
}