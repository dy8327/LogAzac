package com.logazac.controller;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

/**
 * spring.servlet.multipart.max-file-size(20MB)를 넘는 업로드는
 * 컨트롤러 메서드가 호출되기 전에 예외가 발생하기 때문에
 * LogAnalysisController 안의 try/catch로는 잡히지 않는다.
 * 여기서 잡아서 업로드 화면으로 친절하게 되돌려준다.
 */
@ControllerAdvice(assignableTypes = LogAnalysisController.class)
public class LogAnalysisExceptionHandler {

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public String handleMaxSizeExceeded(Model model) {

        model.addAttribute("errorMessage", "파일 용량이 너무 큽니다. 20MB 이하의 파일만 업로드할 수 있습니다.");

        return "analysis/upload";
    }
}
