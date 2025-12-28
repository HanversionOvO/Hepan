export enum HomePageIndexEnum {
  CONTENT,
  POST,
  MESSAGE,
  MINE
}

@ObservedV2
export class HomePageIndexModel {
  @Trace currentIndex: HomePageIndexEnum = HomePageIndexEnum.CONTENT;
}