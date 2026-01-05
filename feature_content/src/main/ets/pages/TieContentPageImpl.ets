import { VMManager } from 'base_common';
import { LongTakeTransitionParam } from 'base_ui';
import { TieContentPageVM } from '../views/TieContentPageVM';

@ComponentV2
export struct TieContentPageImpl {
  @Local vm: TieContentPageVM = VMManager.get(TieContentPageVM, () => new TieContentPageVM());

  build() {
    NavDestination() {
      Text("test")
    }
    .hideTitleBar(true)
    .backgroundColor(this.vm.longTakeSession.navDestinationBgColor)
    .backdropBlur(this.vm.longTakeSession.bgBlurRadius)
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.vm.longTakeSession.setNewSize(newValue);
    })
    .backgroundColor($r('app.color.start_window_background'))
    .onReady((navDestContext: NavDestinationContext) => {
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