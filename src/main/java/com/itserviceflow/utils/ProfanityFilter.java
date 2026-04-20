package com.itserviceflow.utils;

import java.util.Arrays;
import java.util.List;

public class ProfanityFilter {

    private static final List<String> BANNED_WORDS = Arrays.asList(
        "vãi", "chó", "mẹ kiếp", "ma túy", "pod",
        "fuck", "shit", "bitch", "asshole", "bastard", "damn"
    );

    /**
     * Trả về từ vi phạm đầu tiên tìm thấy, hoặc null nếu không có.
     */
    public static String findBannedWord(String text) {
        if (text == null || text.isEmpty()) return null;
        String lower = text.toLowerCase();
        for (String word : BANNED_WORDS) {
            if (lower.contains(word.toLowerCase())) {
                return word;
            }
        }
        return null;
    }

    /**
     * Trả về true nếu text chứa từ độc hại.
     */
    public static boolean containsBannedWord(String text) {
        return findBannedWord(text) != null;
    }
}