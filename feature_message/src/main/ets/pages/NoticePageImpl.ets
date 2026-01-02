@ComponentV2
export struct NoticePageImpl {
  build() {
    NavDestination()
      .hideTitleBar(true)
      .backgroundColor($r('app.color.start_window_background'))
  }
}