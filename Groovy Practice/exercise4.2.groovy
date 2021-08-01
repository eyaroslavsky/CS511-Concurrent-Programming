import java.util.concurrent.Semaphore;

Semaphore mutex1 = new Semaphore(0);
Semaphore mutex2 = new Semaphore(0);

Thread.start {
    mutex1.acquire();
    print("A");
    print("C");
    mutex2.release();
}

Thread.start {
    print("R");
    mutex1.release();
    mutex2.acquire();
    print("E");
    print("S");
}