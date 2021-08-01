import java.util.concurrent.Semaphore;

Semaphore mutex1 = new Semaphore(0);
Semaphore mutex2 = new Semaphore(0);

Thread.start {
    print("A");   
    mutex1.release();
    print("B");
    mutex2.acquire();
    print("C");
}

Thread.start {
    mutex1.acquire();
    print("E");    
    print("F");
    mutex2.release();
    print("G");
}