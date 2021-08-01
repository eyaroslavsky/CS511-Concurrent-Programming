import java.util.concurrent.Semaphore;

Semaphore mutex1 = new Semaphore(0);
Semaphore mutex2 = new Semaphore(0);
Semaphore mutex3 = new Semaphore(0);

Thread.start {
    print("R");
    mutex1.release();
    mutex3.acquire();
    print("OK");
}

Thread.start {
    mutex1.acquire();
    print("I");
    mutex2.release();
    mutex3.acquire();
    print("OK");
}

Thread.start {
    mutex2.acquire();
    print("O");
    mutex3.release();
    mutex3.release();
    print("OK");
}

return;