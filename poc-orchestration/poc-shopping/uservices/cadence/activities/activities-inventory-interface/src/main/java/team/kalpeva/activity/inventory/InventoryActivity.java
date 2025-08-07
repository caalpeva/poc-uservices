package team.kalpeva.activity.inventory;

import com.uber.cadence.activity.ActivityMethod;

public interface InventoryActivity {

    @ActivityMethod(scheduleToCloseTimeoutSeconds = 5)
    String calculate(String greeting, String name);
}