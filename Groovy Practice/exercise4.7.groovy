import java.util.concurrent.Semaphore;

Semaphore mutex1 = new Semaphore(0);
Semaphore mutex2 = new Semaphore(1);

Thread.start {
    10.times {
        mutex2.acquire();
        print("A");
        mutex1.release();
    }
}

Thread.start {
    10.times {
        mutex1.acquire();
        print("B");
        mutex2.release();
    }
}