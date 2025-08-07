package team.kalpeva.activity.inventory;

import com.uber.cadence.activity.Activity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class InventoryActivityImpl implements InventoryActivity {

    private final static Logger logger = LoggerFactory.getLogger(InventoryActivityImpl.class);

    @Override
    public String calculate(String greeting, String name) {
        //logger.info("From {}", Activity.getWorkflowExecution());
        return greeting + " " + name + "!";
    }
}