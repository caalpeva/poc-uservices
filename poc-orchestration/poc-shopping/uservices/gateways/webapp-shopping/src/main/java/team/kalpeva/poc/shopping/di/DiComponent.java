package team.kalpeva.poc.shopping.di;

import dagger.Component;
import team.kalpeva.poc.shopping.verticle.ShoppingVerticle;

import javax.inject.Singleton;

@Singleton
@Component(modules = {HandlerModule.class, ManagerModule.class})
public interface DiComponent {
  //void inject(ShoppingVerticle verticle);
  ShoppingVerticle mainVerticle();
}
