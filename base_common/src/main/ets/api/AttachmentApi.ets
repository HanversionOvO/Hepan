import { fileIo } from '@kit.CoreFileKit';
import { http } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
import { ApiClient } from './ApiClient';
import { UploadedFile, UploadResponse } from './models/MessageModels'; // 确保引入 UploadedFile
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[AttachmentApi]';

const BASE_URL = 'https://bbs.uestc.edu.cn';

export class AttachmentApi {
  /**
   * 上传图片
   * @param fileUri 图片文件的 URI
   * @returns 上传后的附件对象信息
   */
  public static async uploadImage(fileUri: string): Promise<UploadedFile> {
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
      let fileHead = `--${boundary}${lineBreak}`;
      fileHead += `Content-Disposition: form-data; name="files[]"; filename="upload.jpg"${lineBreak}`;
      fileHead += `Content-Type: image/jpeg${lineBreak}${lineBreak}`;

      // 5. 构建结尾部分
      const fileTail = `${lineBreak}--${boundary}--${lineBreak}`;

      // 6. 拼接所有 Buffer
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
      const contentType = `multipart/form-data; boundary=${boundary}`;

      const response = await ApiClient.getInstance().request<UploadResponse>({
        path: '/_/attachment/upload',
        method: http.RequestMethod.POST,
        headers: {
          'Content-Type': contentType
        },
        data: totalBuffer.buffer,
        includeAuthorization: true,
        includeCookie: true
      });

      // 8. 解析结果 (修改返回值逻辑)
      if (response.status === 200 && response.data.data?.uploaded?.length > 0) {
        const uploadedFile = response.data.data.uploaded[0];
        // 补充完整 URL 方便前端显示
        let relativePath = uploadedFile.thumbnail_url || uploadedFile.path || uploadedFile.raw_url;
        if (relativePath && !relativePath.startsWith('http')) {
          const fullUrl = BASE_URL + relativePath;
          if (uploadedFile.thumbnail_url) {
            uploadedFile.thumbnail_url = BASE_URL + uploadedFile.thumbnail_url;
          }
          if (uploadedFile.raw_url) {
            uploadedFile.raw_url = BASE_URL + uploadedFile.raw_url;
          }
          // 我们依然可以临时把用于显示的 url 存入 path 或其他字段，或者直接返回整个对象
        }
        return uploadedFile;
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