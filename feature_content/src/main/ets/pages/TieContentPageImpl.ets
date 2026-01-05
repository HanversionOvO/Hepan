@ComponentV2
export struct TieContentPageImpl {
  build() {
    NavDestination()
      .hideTitleBar(true)
      .backgroundColor($r('app.color.start_window_background'))
  }
}