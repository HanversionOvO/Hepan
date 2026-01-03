import { fileIo } from '@kit.CoreFileKit';
import { http } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
import { ApiClient } from './ApiClient';
import { UploadResponse } from './models/MessageModels';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[AttachmentApi]';

const BASE_URL = 'https://bbs.uestc.edu.cn';

export class AttachmentApi {
  /**
   * 上传图片
   * @param fileUri 图片文件的 URI
   * @returns 上传后的图片 URL (raw_url)
   */
  public static async uploadImage(fileUri: string): Promise<string> {
    let file: fileIo.File | undefined;
    try {
      // 1. 读取文件数据
      file = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(file.fd);
      const fileBuffer = new ArrayBuffer(stat.size);
      fileIo.readSync(file.fd, fileBuffer);
      fileIo.closeSync(file);
      file = undefined;

      // 2. 定义 Boundary 和换行符
      const boundary = `----WebKitFormBoundary${new Date().getTime()}`;
      const lineBreak = '\r\n';
      const encoder = new util.TextEncoder();

      // 3. 构建文本参数部分 (kind=forum, type=image)
      let textBody = '';
      // 参数: kind
      textBody += `--${boundary}${lineBreak}`;
      textBody += `Content-Disposition: form-data; name="kind"${lineBreak}${lineBreak}`;
      textBody += `forum${lineBreak}`;
      // 参数: type
      textBody += `--${boundary}${lineBreak}`;
      textBody += `Content-Disposition: form-data; name="type"${lineBreak}${lineBreak}`;
      textBody += `image${lineBreak}`; // 图片必须是 image

      // 4. 构建文件头部分
      // 注意: filename 可以随便取，Content-Type 设为 image/jpeg 即可通用
      let fileHead = `--${boundary}${lineBreak}`;
      fileHead += `Content-Disposition: form-data; name="files[]"; filename="upload.jpg"${lineBreak}`;
      fileHead += `Content-Type: image/jpeg${lineBreak}${lineBreak}`;

      // 5. 构建结尾部分
      const fileTail = `${lineBreak}--${boundary}--${lineBreak}`;

      // 6. 拼接所有 Buffer
      // ArkTS 中需要使用 Uint8Array 进行拼接
      const textBodyBuffer = encoder.encodeInto(textBody);
      const fileHeadBuffer = encoder.encodeInto(fileHead);
      const fileTailBuffer = encoder.encodeInto(fileTail);

      const totalLength =
        textBodyBuffer.byteLength + fileHeadBuffer.byteLength + fileBuffer.byteLength + fileTailBuffer.byteLength;
      const totalBuffer = new Uint8Array(totalLength);

      let offset = 0;
      totalBuffer.set(textBodyBuffer, offset);
      offset += textBodyBuffer.byteLength;

      totalBuffer.set(fileHeadBuffer, offset);
      offset += fileHeadBuffer.byteLength;

      totalBuffer.set(new Uint8Array(fileBuffer), offset);
      offset += fileBuffer.byteLength;

      totalBuffer.set(fileTailBuffer, offset);

      // 7. 发送请求
      // 注意：Content-Type 必须包含 boundary
      const contentType = `multipart/form-data; boundary=${boundary}`;

      // 使用 ApiClient 发送请求，注意 data 类型此时是 ArrayBuffer
      const response = await ApiClient.getInstance().request<UploadResponse>({
        path: '/_/attachment/upload',
        method: http.RequestMethod.POST,
        headers: {
          'Content-Type': contentType
        },
        data: totalBuffer.buffer, // 传递 ArrayBuffer 给 extraData
        includeAuthorization: true,
        includeCookie: true
      });

      // 8. 解析结果
      if (response.status === 200 && response.data.data?.uploaded?.length > 0) {
        const uploadedFile = response.data.data.uploaded[0];
        let relativePath = uploadedFile.thumbnail_url || uploadedFile.path || uploadedFile.raw_url;
        if (relativePath && !relativePath.startsWith('http')) {
          return BASE_URL + relativePath;
        }
        return relativePath!;
      } else {
        throw new Error(`Upload failed: ${response.data.message || 'Unknown error'}`);
      }
    } catch (e) {
      LogUtil.error(TAG, `Upload image failed: ${JSON.stringify(e)}`);
      throw new Error(e);
    } finally {
      if (file) {
        fileIo.closeSync(file);
      }
    }
  }
}