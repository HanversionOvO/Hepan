import { BaseVM, BreakpointNameEnum, BreakpointType, CommonConstant } from 'base_common';
import { ApplicationCardItem } from '../components/ApplicationCard';

@ObservedV2
export class ApplicationVM extends BaseVM {
  @Trace applications: ApplicationCardItem[] = [];
  @Trace columns: number = 2;
  @Trace minColumns: number = 1;
  @Trace maxColumns: number = 3;
  @Trace pageScale: number = 1;

  @Monitor("breakPoint.currentBreakPoint")
  onBreakpointChange() {
    this.updateGridConfig(this.breakPoint.currentBreakPoint);
  }

  private defaultColumnsConfig = new BreakpointType({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 4
  });

  updateGridConfig(bp: BreakpointNameEnum) {
    this.columns = this.defaultColumnsConfig.getValue(bp);
  }

  async loadData() {
    this.applications = [
      new ApplicationCardItem({
        icon: $r('sys.symbol.drop_fill'),
        name: "水滴",
        iconColor: CommonConstant.InfoColor,
        desc: "水滴的XXX"
      })
    ];

    this.updateGridConfig(this.breakPoint.currentBreakPoint)
  }
}