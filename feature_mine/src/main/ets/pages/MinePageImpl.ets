import { MinePageVM } from '../viewmodels/MinePageVM';
import { MinePageView } from '../views/MinePageView';

@ComponentV2
export struct MinePageImpl {
  @Local vm: MinePageVM = new MinePageVM()

  async aboutToAppear() {
    this.vm.init('me');
    await this.vm.startMine();
  }

  build() {
    MinePageView({ vm: this.vm })
  }
}
