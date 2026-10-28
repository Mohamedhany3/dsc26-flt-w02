# AI usage: dsc26-flt-w02

## 1. Tools I used

I used ChatGPT to understand the task requirements, write Flutter code, and fix errors.

## 2. The two or three most useful prompts

1. Help me implement AlertsViewModel using ChangeNotifier with sorting, filtering, and searching.
2. Help me create a simple Flutter UI with colors and an Acknowledge button.
3. Help me fix Flutter test failures and understand the errors.

## 3. One thing the AI got wrong or left out, and how I found it

The AI displayed "Alerts: 2" instead of "2 alerts". I found this mistake when I ran the public tests. After fixing it, all five tests passed.

## 4. Why `visibleAlerts` lives in the view model and not in the screen

[Write your own two sentences here. Your idea: the ViewModel handles filtering and sorting, while the UI displays the results. This improves code quality, readability, and maintainability.]