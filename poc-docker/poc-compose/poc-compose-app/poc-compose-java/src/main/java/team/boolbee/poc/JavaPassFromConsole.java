package team.boolbee.poc;

import de.audioattack.io.ConsoleCreator;
import de.audioattack.io.Console;
import java.util.Arrays;

public class JavaPassFromConsole {
    public static void main (String[] args) {
        Console console = ConsoleCreator.console();
        String login = console.readLine("Enter your login: ");
        char[] oldPassword = console.readPassword("Enter your old password: ");

        if (verify(login, oldPassword)) {
            boolean match =false;
            while(!match) {
                char[] newPassword1 = console.readPassword("Enter your new password: ");
                char[] newPassword2 = console.readPassword("Enter new password again: ");
                match = Arrays.equals(newPassword1, newPassword2);
                if (match) {
                    change(login, newPassword1);
                    console.format("Password for %s changed.%n", login);
                } else {
                    console.format("Passwords don't match. Try again.%n");
                }
                Arrays.fill(newPassword1, ' ');
                Arrays.fill(newPassword2, ' ');
            }
        }

        Arrays.fill(oldPassword, ' ');
    }

    // Method for verifying the password
    static boolean verify(String login, char[] password) {
        return true;
    }

    // Method for changing the password
    static void change(String login, char[] password) {
    }
}