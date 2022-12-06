package team.boolbee.poc;

import java.io.Console;
import java.util.Arrays;

public class JavaPassFromConsole {
    public static void main (String[] args) {
        Console c = System.console();
        String login = c.readLine("Enter your login: ");
        char[] oldPassword = c.readPassword("Enter your old password: ");

        if (verify(login, oldPassword)) {
            boolean match =false;
            while(!match) {
                char[] newPassword1 = c.readPassword("Enter your new password: ");
                char[] newPassword2 = c.readPassword("Enter new password again: ");
                match = Arrays.equals(newPassword1, newPassword2);
                if (match) {
                    change(login, newPassword1);
                    c.format("Password for %s changed.%n", login);
                } else {
                    c.format("Passwords don't match. Try again.%n");
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