import java.util.concurrent.Semaphore;

Semaphore permToLoad = new Semaphore(1);
Semaphore doneLoading = new Semaphore(0);

tracks = [new Semaphore(1), new Semaphore(1)];

Thread.start { //Passenger Train
    Random rnd = new Random()
    int dir = rnd.nextInt(1);
    
    tracks[dir].acquire();
    
    tracks[dir].release();
}

Thread.start { //Freight Train
    Random rnd = new Random()
    int dir = rnd.nextInt(1);
    
    tracks[0].acquire();
    tracks[1].acquire();
    permToLoad.release();
    
    doneLoading.acquire();
    tracks[0].release();
    tracks[1].release();
}

Thread.start { //Loading machine
    permToLoad.acquire();
    
    doneLoading.release();
}