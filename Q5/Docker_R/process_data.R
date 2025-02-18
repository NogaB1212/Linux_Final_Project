# טעינת חבילות נדרשות
library(dplyr)
library(ggplot2)

# קביעת קבצי קלט ופלט
input_csv <- "Demo_CSV.csv"
output_file <- "5_R_outputs.txt"
plot_file <- "weight_distribution.png"

# קריאת הנתונים
df <- read.csv(input_csv)

# פתיחת קובץ לכתיבת התוצאות
sink(output_file)

# חישוב משקל ממוצע לכל מין
cat("Mean Weight by Species:\n")
df %>%
  group_by(Species) %>%
  summarise(Mean_Weight = mean(Weight, na.rm = TRUE)) %>%
  print()
cat("\n")

# ספירת מספר הרשומות לכל מין
cat("Count of Records per Species:\n")
df %>%
  group_by(Species) %>%
  summarise(Count = n()) %>%
  print()
cat("\n")

# מיון הנתונים לפי משקל (מהכבד לקל)
cat("Top 10 Heaviest Animals:\n")
df %>%
  arrange(desc(Weight)) %>%
  head(10) %>%
  print()
cat("\n")

# יצירת גרף: התפלגות משקל לפי מין
cat("Saving Plot: Weight Distribution by Sex\n")
ggplot(df, aes(x = Weight, fill = Sex)) +
  geom_histogram(bins = 20, alpha = 0.7, position = "identity") +
  labs(title = "Weight Distribution by Sex", x = "Weight", y = "Count") +
  theme_minimal()
ggsave(plot_file)
cat("Plot saved as:", plot_file, "\n\n")

# סגירת קובץ הפלט
sink()
