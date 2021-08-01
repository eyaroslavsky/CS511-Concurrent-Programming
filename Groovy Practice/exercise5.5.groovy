import java.util.concurrent.Semaphore;

Semaphore station0 = new Semaphore(1);
Semaphore station1 = new Semaphore(0);
Semaphore station2 = new Semaphore(0);
Semaphore blast = new Semaphore(0);
Semaphore rinse = new Semaphore(0);
Semaphore dry = new Semaphore(0);

100.times {
    int car_id = it;
    Thread.start { // car
        println("Car " + car_id + " is waiting to get washed");
        
        station0.acquire();
        blast.release();
        println("Car " + car_id + " is getting blasted");
        rinse.acquire();
        
        station1.acquire();
        station0.release();
        
        rinse.release();      
        println("Car " + car_id + " is getting rinsed");
        dry.acquire();
        
        station2.acquire();
        station1.release();
        
        dry.release();
        println("Car " + car_id + " is getting dried");
        leave.acquire();
        station2.release();
        
        println("Car " + car_id + " has been washed");
    }
}

Thread.start { // blast
    blast.acquire();
    
    rinse.release();
}

Thread.start { // rinse
    rinse.acquire();
    
    dry.release();
}

Thread.start { // dry
    dry.acquire();
    
    leave.release();
}