@Builder
export function FansPageBuilder() {
  FansPage();
}

@ComponentV2
struct FansPage {
  build() {
    NavDestination() {
      
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
  }
}