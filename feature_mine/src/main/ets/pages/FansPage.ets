@Builder
export function FansPageBuilder() {
  FansPage();
}

@ComponentV2
struct FansPage {
  build() {
    NavDestination()
    .hideTitleBar(true)
  }
}