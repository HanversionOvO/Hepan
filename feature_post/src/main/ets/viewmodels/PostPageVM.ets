import { BaseVM } from 'base_common';
import { NavTitleButtonModel } from 'base_ui';

@ObservedV2
export class PostPageVM extends BaseVM {
  @Trace titleButtons: NavTitleButtonModel[] = [];
  @Trace uploadedImages: string[] = [
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
    'https://t.alcy.cc/pc',
  ];
}