public class Swapper implements Runnable {
	private int offset;
    private Interval interval;
    private String content;
    private char[] buffer;

    public Swapper(Interval interval, String content, char[] buffer, int offset) {
        this.offset = offset;
        this.interval = interval;
        this.content = content;
        this.buffer = buffer;
    }

    @Override
    public void run() {
        // TODO: Implement me!
    	int begin = this.interval.getX();
    	int end = this.interval.getY() + 1;
    	this.content.getChars(begin, end, this.buffer, this.offset);
    }
}
