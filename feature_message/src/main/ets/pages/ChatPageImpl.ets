@ComponentV2
export struct ChatPageImpl {
  build() {
    NavDestination()
      .hideTitleBar(true)
      .backgroundColor($r('app.color.start_window_background'))
  }
}