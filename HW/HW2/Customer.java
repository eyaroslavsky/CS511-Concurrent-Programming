import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

public class Customer implements Runnable {
    private Bakery bakery;
    private Random rnd;
    private List<BreadType> shoppingCart;
    private int shopTime;
    private int checkoutTime;

    /**
     * Initialize a customer object and randomize its shopping cart
     */
    public Customer(Bakery bakery) {
        // TODO
    	this.bakery = bakery;
    	this.rnd = new Random();
    	this.shoppingCart = new ArrayList<BreadType>();
    	this.fillShoppingCart();
    	this.shopTime = rnd.nextInt(333);
    	this.checkoutTime = rnd.nextInt(1000);
    }

    /**
     * Run tasks for the customer
     */
    public void run() {
        // TODO
    	try {
    		System.out.println(this.toString());
    		float price = 0;
	    	for (int i = 0; i < shoppingCart.size(); i++) {
	    		if (shoppingCart.get(i) == BreadType.RYE) {	    			
	        		bakery.breadLineRye.acquire();
	    			bakery.takeBread(shoppingCart.get(i));
	    			System.out.println("Customer " + hashCode() + " took " + shoppingCart.get(i));
	    			price += shoppingCart.get(i).getPrice();
	    			Thread.sleep(shopTime);
	    			bakery.breadLineRye.release();
	    		}
	    		else if (shoppingCart.get(i) == BreadType.SOURDOUGH) {	    			
	        		bakery.breadLineSourdough.acquire();
	    			bakery.takeBread(shoppingCart.get(i));
	    			System.out.println("Customer " + hashCode() + " took " + shoppingCart.get(i));
	    			price += shoppingCart.get(i).getPrice();
	    			Thread.sleep(shopTime);
	    			bakery.breadLineSourdough.release();
	    		}
	    		else {    			
	        		bakery.breadLineWonder.acquire();
	    			bakery.takeBread(shoppingCart.get(i));
	    			System.out.println("Customer " + hashCode() + " took " + shoppingCart.get(i));
	    			price += shoppingCart.get(i).getPrice();
	    			Thread.sleep(shopTime);
	    			bakery.breadLineWonder.release();
	    		}  		
	    	}
	    	
	    	bakery.checkoutLine.acquire();	    
	    	System.out.println("Customer " + hashCode() + " went to checkout.");
	    	bakery.addSales(price);
	    	Thread.sleep(checkoutTime);
	    	bakery.checkoutLine.release();
    	}
    	catch (Exception e) {
    		System.out.println("Thread Interrupted");
    	}
    	   	
    }

    /**
     * Return a string representation of the customer
     */
    public String toString() {
        return "Customer " + hashCode() + ": shoppingCart=" + Arrays.toString(shoppingCart.toArray()) + ", shopTime=" + shopTime + ", checkoutTime=" + checkoutTime;
    }

    /**
     * Add a bread item to the customer's shopping cart
     */
    private boolean addItem(BreadType bread) {
        // do not allow more than 3 items, chooseItems() does not call more than 3 times
        if (shoppingCart.size() >= 3) {
            return false;
        }
        shoppingCart.add(bread);
        return true;
    }

    /**
     * Fill the customer's shopping cart with 1 to 3 random breads
     */
    private void fillShoppingCart() {
        int itemCnt = 1 + rnd.nextInt(3);
        while (itemCnt > 0) {
            addItem(BreadType.values()[rnd.nextInt(BreadType.values().length)]);
            itemCnt--;
        }
    }

    /**
     * Calculate the total value of the items in the customer's shopping cart
     */
    private float getItemsValue() {
        float value = 0;
        for (BreadType bread : shoppingCart) {
            value += bread.getPrice();
        }
        return value;
    }
}