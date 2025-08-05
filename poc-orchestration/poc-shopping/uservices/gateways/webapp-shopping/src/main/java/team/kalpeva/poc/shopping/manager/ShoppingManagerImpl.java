package team.kalpeva.poc.shopping.manager;

import io.reactivex.rxjava3.core.Single;
import team.kalpeva.poc.shopping.model.ShoppingRequest;
import team.kalpeva.poc.shopping.model.WorkflowResponse;

import javax.inject.Inject;

public class ShoppingManagerImpl implements ShoppingManager {

    @Inject
    public ShoppingManagerImpl() {

    }

    @Override
    public Single<WorkflowResponse> manage(ShoppingRequest request) {
        return Single.just(WorkflowResponse.builder()
                .message("HOLA PERICOOOOOOOO")
                .build());
    }
}
