import java.util.concurrent.Semaphore;

Semaphore accessJ = new Semaphore(0);
Semaphore mutex = new Semaphore(1);

100.times { // P
    Thread.start {
        print("P");
        accessJ.release();
    }
}

100.times { // J
    Thread.start {
        mutex.acquire();
        accessJ.acquire();
        print("J");
        accessJ.acquire();
        mutex.release();
    }
}