package team.kalpeva.poc.shopping.manager;

import io.reactivex.rxjava3.core.Single;
import team.kalpeva.poc.shopping.model.ShoppingRequest;
import team.kalpeva.poc.shopping.model.ShoppingResponse;
import team.kalpeva.poc.shopping.model.WorkflowResponse;

public interface ShoppingManager {
    Single<WorkflowResponse> manage(ShoppingRequest request);
}
