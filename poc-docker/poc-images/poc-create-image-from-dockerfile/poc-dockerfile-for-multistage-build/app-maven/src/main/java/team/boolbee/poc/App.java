package team.boolbee.poc;

/**
 * Hello world!
 */
public class App
{
    private final String message = "Hello World!";

    public App() {}

    private final String getMessage() {
        return message;
    }

    public static void main(String[] args) {
        System.out.println(new App().getMessage());
    }
}
