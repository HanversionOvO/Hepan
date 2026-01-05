/**
 * LazyForEach 通用数据源实现
 * 封装了 IDataSource 接口的基本实现和常用数据操作方法
 */
export class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: T[] = [];

  public totalCount(): number {
    return this.originDataArray.length;
  }

  public getData(index: number): T {
    return this.originDataArray[index];
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处移除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  // --- 通知 LazyForEach 组件更新的方法 ---

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  // --- 业务层调用的数据操作方法 ---

  /**
   * 设置全新数据（重置列表）
   */
  public setData(data: T[]) {
    this.originDataArray = data;
    this.notifyDataReload();
  }

  /**
   * 在列表末尾追加多条数据（用于上拉加载更多）
   */
  public addData(data: T[]) {
    this.originDataArray = this.originDataArray.concat(data);
    this.notifyDataAdd(this.originDataArray.length - data.length);
  }

  /**
   * 在列表末尾追加单条数据
   */
  public pushData(data: T) {
    this.originDataArray.push(data);
    this.notifyDataAdd(this.originDataArray.length - 1);
  }

  /**
   * 获取所有数据
   */
  public getAllData(): T[] {
    return this.originDataArray;
  }
}