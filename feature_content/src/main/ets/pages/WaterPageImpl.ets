import { CardLongTakeDelegate, LongTakeTransitionParam } from 'base_ui';
import { WaterVM } from '../viewmodels/WaterVM';
import { WaterView } from '../views/WaterView';

@ComponentV2
export struct WaterPageImpl {
  @Local vm: WaterVM = new WaterVM();

  @Builder
  ContentBuilder() {
    WaterView({ vm: this.vm })
  }

  build() {
    NavDestination() {
      if (this.vm.longTakeSession) {
        CardLongTakeDelegate({
          longTakeSession: this.vm.longTakeSession,
          contentBuilder: (): void => {
            this.ContentBuilder()
          },
        })
      } else {
        this.ContentBuilder()
      }
    }
    .hideTitleBar(true)
    .backgroundColor(this.vm.longTakeSession.navDestinationBgColor)
    .backdropBlur(this.vm.longTakeSession.bgBlurRadius)
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.vm.longTakeSession.setNewSize(newValue);
    })
    .onReady(async (navDestContext: NavDestinationContext) => {
      let params = navDestContext.pathInfo?.param as Record<string, Object>;
      if (params) {
        if (params["transition"]) {
          const transitionParam: LongTakeTransitionParam = params["transition"] as LongTakeTransitionParam;
          this.vm.longTakeSession.init(navDestContext, transitionParam, {
            pop: () => {
              navDestContext.pathStack.pop()
            },
          });
        }
      }
    })
  }
}