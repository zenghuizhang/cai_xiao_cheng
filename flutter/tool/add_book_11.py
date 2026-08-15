#!/usr/bin/env python3
# 向 books 段追加《持续买入》(Just Keep Buying)，内容为原创大白话导读。
import json

PATH = 'assets/data/knowledge_base.json'

bk11 = {
    "id": "BK11",
    "title": "持续买入",
    "author": "尼克·马吉奥利（Nick Maggiulli）",
    "level": 2,
    "cover_emoji": "🔁",
    "tags": ["定投", "储蓄率", "不择时", "长期持有"],
    "one_line": "别等最佳时机，一直买",
    "why_read": "作者用两百年历史数据，回答了工薪族最纠结的两个问题：到底该存多少钱？手上有笔钱，是一次性投进去还是分批买？结论反直觉，却特别好操作。",
    "core_ideas": [
        {"idea": "攒钱靠储蓄率，变富靠拥有资产", "explain": "光把钱存银行，利息很难跑赢通胀。想真正变富，必须买入并长期持有能产生回报的资产——这就是「让钱为你工作」。储蓄决定你有多少种子，投资决定种子能长成什么样。"},
        {"idea": "别等「最佳时机」，持续买入", "explain": "没人能持续预测涨跌。数据显示，哪怕你很倒霉地恰好在历史最高点开始买，只要坚持定投、拿得够久，结果也比一直持币观望、等待回调要好。等「跌了再买」往往等来更高的价格。"},
        {"idea": "一次性投入 vs 分批买", "explain": "历史上一次性投入大约三分之二的时间跑赢分批买入，因为市场长期向上。但如果分批发工资、或者一次性投入会让你焦虑到睡不着、在下跌时割肉，那么定投对你就是更好的策略——拿得住，比理论最优更重要。"},
        {"idea": "储蓄率是你最能控制的事", "explain": "明年涨多少、利率多少，你说了不算；但这个月存下收入的百分之多少，你说了算。收入再高月光也留不住钱；老老实实提高储蓄率，比追求「高收益」更实在、更可控。"},
        {"idea": "下跌时最该做的是继续买", "explain": "市场大跌时，同样的钱能买到更多份额，相当于打折囤货。书里反复强调：崩盘不是世界末日，对长期定投者反而是机会。恐慌清仓的人，才把账面浮亏变成了真亏。"}
    ],
    "takeaways": [
        "你能控制的是存多少、坚持多久；控制不了的是明天的涨跌。",
        "最好的买入时机可能是昨天，第二好的是现在。",
        "让你拿得住、睡得着的策略，就是对你最好的策略。",
        "收入是河水，储蓄是水库，投资是把水库的水拿去种果树。"
    ],
    "for_whom": "总在纠结「现在是不是高点、要不要等跌了再买」，以及想搞清楚该存多少钱、一次性买还是分批买的工薪族。",
    "read_path": "全书很易读、数据多但不枯燥。重点看「储蓄率」「一次性投入 vs 定投」「熊市应对」几章；退休后怎么取钱的部分可按需翻阅。",
    "related_chapters": ["C2", "C3"]
}

with open(PATH, encoding='utf-8') as f:
    data = json.load(f)

books = data.setdefault('books', [])
books = [b for b in books if b.get('id') != 'BK11']
books.append(bk11)
# 按 id 排序
books.sort(key=lambda b: b['id'])
data['books'] = books
data['meta']['content_version'] = '3'
data['meta']['updated_at'] = '2026-08-09'

with open(PATH, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f'OK: {len(books)} books; titles: {[b["title"] for b in books]}')
