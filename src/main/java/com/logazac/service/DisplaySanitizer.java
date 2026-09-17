package com.logazac.service;
import java.util.regex.Pattern;
public final class DisplaySanitizer {
    private DisplaySanitizer() {}
    private static final Pattern PARTNER = Pattern.compile("(?i)코레일(?:유통)?|korail|kov_send|drim(?:hitech|hightech)?|joun(?:system)?|조은|smartm|toygo");
    private static final Pattern CARD = Pattern.compile("(?i)((?:CARDNO|Card_no|APPROVAL|CATID|MID|AFFILIATE)=)[^\\s&]+");
    public static String redact(String value) {
        if (value == null) return null;
        return CARD.matcher(PARTNER.matcher(value).replaceAll("외부시스템")).replaceAll("$1[비공개]");
    }
}
