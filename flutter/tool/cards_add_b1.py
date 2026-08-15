#!/usr/bin/env python3
"""批 1：新增卡片 C1_016~020、C2_026~030 + 新题 QZ_C1_06/07、QZ_C2_06/07/08"""
import json

KB = 'assets/data/knowledge_base.json'

NEW_CARDS = [
    # ============ C1 新增 5 张 ============
    {"id": "C1_016", "chapter": 1, "order_index": 16,
     "title": "钱的三笔账：应急、保命、生钱",
     "daily_analogy": "过年收到的红包，聪明人会分成三份：一份放枕头底下随时能拿（应急），一份锁进抽屉坚决不动（保命），一份拿去请小老板合伙开店（生钱）。钱也是一样，先分好工，才不会一着急就全砸在一个地方。",
     "core_knowledge": "把钱分成三笔：①应急金——3-6个月生活费，随时可取；②保命钱——几年内不动的长期资金，投稳健工具；③生钱钱——能承受波动的闲钱。顺序不能乱：先建应急金，再谈投资。",
     "illustration_note": "三个不同颜色的存钱罐：红罐标「应急」、蓝罐标「保命」、绿罐标「生钱」",
     "glossary_terms": ["应急金", "流动性"],
     "points": 10, "difficulty": 1,
     "related_quiz_id": "QZ_C1_06"},
    {"id": "C1_017", "chapter": 1, "order_index": 17,
     "title": "记账 30 天：先知道钱去哪了",
     "daily_analogy": "减肥第一步不是买课，是上秤看体重。理财第一步也不是买基金，是先记一个月账：月底你会发现，楼下那杯奶茶、拼单的零食，加起来的数字比想象中吓人。看见，才有得改。",
     "core_knowledge": "记账的价值不在「记」，而在「复盘」。连续记30天，把支出分成必要、需要、想要三类：必要留下，需要压缩，想要砍半。摸清自己的现金流出入口，才能谈储蓄率和投资本金。",
     "illustration_note": "一本打开的记账本，旁边一杯奶茶和一张发票，用放大镜盯着",
     "glossary_terms": ["现金流", "结余"],
     "points": 10, "difficulty": 1,
     "related_quiz_id": "QZ_C1_02"},
    {"id": "C1_018", "chapter": 1, "order_index": 18,
     "title": "拿铁因子：小钱漏出的复利反例",
     "daily_analogy": "每天一杯30块的拿铁，一个月900块，一年一万多。这笔钱如果每月定投到年化8%的地方，30年后是130多万。你没穷在房租上，你是穷在那些不起眼的「小钱」上——它们偷偷搭上了复利的反向列车。",
     "core_knowledge": "拿铁因子指那些「小到看不见」的习惯性支出（奶茶、会员、免密订阅）。它们单个不起眼，但每月叠加再错过复利，差距以十万计。方法不是苦行戒掉一切，而是识别3个「高频小额」支出，把它们变成储蓄率。",
     "illustration_note": "一杯咖啡变成了一长串硬币滑进储蓄罐的漫画",
     "glossary_terms": ["复利", "机会成本"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C1_07"},
    {"id": "C1_019", "chapter": 1, "order_index": 19,
     "title": "储蓄率：先付给自己",
     "daily_analogy": "发工资那天，钱还没焐热就先花光了——这是「先消费后储蓄」。反过来：工资一到账，先转10%进储蓄账户，剩下的才用来生活——这是「先付给自己」。顺序一换，攒钱从「看心情」变成「看纪律」。",
     "core_knowledge": "储蓄率=每月存下的钱÷收入。新手从10%起步，加到20%、30%也不难。关键是自动化：设置发薪日自动转账，让储蓄发生在「手痒之前」。储蓄率决定你投资本金的起点，也决定你的人生容错率。",
     "illustration_note": "工资条上先切出一块标着「10%」的蛋糕放进储蓄罐，剩下的才上桌",
     "glossary_terms": ["储蓄率", "先储蓄后消费"],
     "points": 10, "difficulty": 1,
     "related_quiz_id": "QZ_C1_02"},
    {"id": "C1_020", "chapter": 1, "order_index": 20,
     "title": "机会成本：选了这个，就没了那个",
     "daily_analogy": "周末你有两个选择：躺一天，或去学一门能加薪的课。躺平的成本不是0——你「失去」的是那门课可能带来的收益。投资的每一次选择也一样：钱放活期，失去的就是定投的长期复利。",
     "core_knowledge": "机会成本=做选择时放弃的那个次优选项的价值。它提醒我们：钱闲置=在亏，存短期=错过长期。衡量一笔投资值不值，不只看它能赚多少，还要看「同样的钱干别的能赚多少」。",
     "illustration_note": "岔路口路牌：一边写「活期0.2%」，一边写「定投8%」，人站在中间犹豫",
     "glossary_terms": ["机会成本", "本金"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C1_07"},
    # ============ C2 新增 5 张 ============
    {"id": "C2_026", "chapter": 2, "order_index": 26,
     "title": "ETF：在交易所里买卖的基金",
     "daily_analogy": "普通基金像「网上下单、晚上统一送货」：申赎要按当天收盘价。ETF更像「菜市场现买现卖」：开盘时就能按实时价格买进卖出，一手起卖，还便宜——它是装在股票壳子里的指数基金。",
     "core_knowledge": "ETF（交易型开放式指数基金）在场内交易，像股票一样实时买卖，费率通常比场外基金更低，没有申购赎回费，只有券商佣金。适合想随时交易、看中低费率的指数投资者；缺点是买卖要有券商账户，且价格实时波动。",
     "illustration_note": "菜市场里一个标着「ETF」的菜摊，摊主指着电子屏上的实时菜价",
     "glossary_terms": ["ETF", "场内交易"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C2_06"},
    {"id": "C2_027", "chapter": 2, "order_index": 27,
     "title": "分红再投资：让利润替你打工",
     "daily_analogy": "果园老板有两招收钱：把果子摘了卖掉（现金分红），或者让果子烂在地里当肥料、明年结更多果（分红再投资）。长期投资者多半选后者——不是缺那点果子，是要让果园自己越滚越大。",
     "core_knowledge": "基金分红有两种选择：现金分红（落袋为安）和红利再投资（分红自动买成份额）。复利角度，红利再投资能把每笔分红立刻变成本金继续滚雪球。熊市分红相当于强制低点买入，长期收益显著优于现金分红。",
     "illustration_note": "一棵果树上，掉落的果子掉回根部变成肥料，树越结越大",
     "glossary_terms": ["分红", "复利"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C2_03"},
    {"id": "C2_028", "chapter": 2, "order_index": 28,
     "title": "选基金看什么：三看三不看",
     "daily_analogy": "点菜不看招牌看什么？看后厨干不干净（规模别太小）、看大众点评分（历史业绩但别只看一年）、看主厨换没换人（经理任职时长）。至于门口排多长的队（近一周涨幅）——那是别人替你抢的，不是你的菜。",
     "core_knowledge": "选基金三看：①看规模——太小有清盘风险，太大船难掉头；②看经理——任职3年以上、风格稳定；③看费率——同类里选费率低的。三不看：不看短期涨幅榜（追高陷阱）、不看宣传语、不看过往1年业绩（幸存者偏差重灾区）。",
     "illustration_note": "一张点菜单，勾选了「规模」「经理」「费率」，划掉了「上周涨最多」",
     "glossary_terms": ["基金", "管理费", "基金经理"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C2_07"},
    {"id": "C2_029", "chapter": 2, "order_index": 29,
     "title": "宽基 vs 行业基金：整条街 vs 奶茶一条街",
     "daily_analogy": "宽基指数基金是「整座城市的平均生意」：有菜场有药店有书店，一家倒闭不影响大局。行业基金是「押注奶茶一条街」：奶茶火了你赚翻，奶茶凉了你陪葬。新手永远先站上整条街。",
     "core_knowledge": "宽基指数（沪深300、中证500）覆盖多个行业，天然分散，适合定投新手。行业指数（白酒、医药、新能源）波动巨大，受政策和技术变革冲击，押错行业可能长期趴窝。新手配置应以宽基为主，行业基金占比不超过20%。",
     "illustration_note": "左图：城市全景地图上很多小店；右图：一条街上全是奶茶店，其中一家在关店",
     "glossary_terms": ["宽基指数", "行业指数"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C2_08"},
    {"id": "C2_030", "chapter": 2, "order_index": 30,
     "title": "房产是资产还是负债",
     "daily_analogy": "一套房子每月收租3000，是资产；一套房子每月要还贷8000、还要交物业费，是负债——区别不看「名字」，看「钱往哪流」。自住房本质上是一个「消费+储蓄」混合体：住得舒服是消费，涨了是意外之喜，别把两者混着算。",
     "core_knowledge": "判断标准：能持续把钱放进你口袋的是资产，持续从口袋掏钱的是负债。自住房在住期间是负债（房贷、物业、维修持续流出），卖出才兑现增值。把房产当投资品，要看租金回报率和流动性——房子最大的缺点是「卖起来太慢」。",
     "illustration_note": "同一栋房子：一边画了租金流进的箭头，一边画了房贷流出的箭头",
     "glossary_terms": ["资产", "负债", "现金流"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C2_04"},
]

NEW_QUIZZES = [
    {"id": "QZ_C1_06", "chapter_id": "C1", "order_index": 6,
     "question": "刚工作的小林，每月到手8000，他应该先做哪一步？",
     "options": ["立刻定投买基金", "先攒3-6个月生活费当应急金", "先买一份分红保险", "借钱补仓股票"],
     "answer_index": 1,
     "explanation": "理财顺序：先建应急金，再谈投资。没有应急金就投资，一遇急事就得割肉。",
     "right_reply": "对！应急金是投资的「安全气囊」，先装好再上路。",
     "wrong_reply": "顺序反啦——没有应急金，急用钱时只能割肉，等于用亏损买教训。",
     "points": 20},
    {"id": "QZ_C1_07", "chapter_id": "C1", "order_index": 7,
     "question": "「拿铁因子」想说明的道理是？",
     "options": ["咖啡不健康所以要戒掉", "高频小额支出长期会吞掉大笔钱", "饮料行业是好赛道", "每天存30块就能发财"],
     "answer_index": 1,
     "explanation": "每天30块看着少，一年上万，30年错过复利就是百万级的差距。",
     "right_reply": "答对！小钱不是省出来的，是「看见」出来的。",
     "wrong_reply": "不是戒咖啡哦——是识别那些高频小额支出，把它们变成储蓄。",
     "points": 20},
    {"id": "QZ_C2_06", "chapter_id": "C2", "order_index": 6,
     "question": "ETF 和普通场外基金最大的区别是？",
     "options": ["ETF 有基金经理，场外没有", "ETF 在交易所里实时买卖，像股票一样", "ETF 风险一定更低", "ETF 不收费"],
     "answer_index": 1,
     "explanation": "ETF 场内实时交易、费率低；场外基金按收盘净值申赎。本质都是基金。",
     "right_reply": "对！ETF 就是「能像股票一样现买现卖」的指数基金。",
     "wrong_reply": "ETF 也有基金经理、也要收费（只是更低），它的特点是场内实时交易。",
     "points": 20},
    {"id": "QZ_C2_07", "chapter_id": "C2", "order_index": 7,
     "question": "选基金时，下面哪一项「不该看」？",
     "options": ["基金规模", "基金经理任职年限", "近一个月涨幅榜", "费率高低"],
     "answer_index": 2,
     "explanation": "短期涨幅榜是追高陷阱：涨最多的往往正要回调。选基金看规模、经理、费率，不看短期榜。",
     "right_reply": "答对！短期涨幅榜是镰刀最爱用的诱饵。",
     "wrong_reply": "规模、经理、费率都要看，唯独短期涨幅榜——那是别人替你抢的菜。",
     "points": 20},
    {"id": "QZ_C2_08", "chapter_id": "C2", "order_index": 8,
     "question": "为什么新手定投优先选宽基指数基金？",
     "options": ["宽基涨得最快", "宽基覆盖多个行业，天然分散，不怕单行业暴雷", "宽基不收管理费", "宽基不会跌"],
     "answer_index": 1,
     "explanation": "宽基覆盖多行业，任何一家公司、一个行业出问题都不致命，适合不择时的新手。",
     "right_reply": "对！整条街的平均生意，比押注奶茶一条街稳得多。",
     "wrong_reply": "宽基也会跌、也收费，它的优势是「天然分散、不押单一行业」。",
     "points": 20},
]

def main():
    with open(KB, encoding='utf-8') as f:
        kb = json.load(f)
    card_ids = {c['id'] for c in kb['cards']}
    quiz_ids = {q['id'] for q in kb['quizzes']}
    added_c = added_q = 0
    for c in NEW_CARDS:
        if c['id'] in card_ids:
            print(f"SKIP 卡片已存在: {c['id']}"); continue
        kb['cards'].append(c); card_ids.add(c['id']); added_c += 1
    for q in NEW_QUIZZES:
        if q['id'] in quiz_ids:
            print(f"SKIP 题目已存在: {q['id']}"); continue
        kb['quizzes'].append(q); quiz_ids.add(q['id']); added_q += 1
    with open(KB, 'w', encoding='utf-8') as f:
        json.dump(kb, f, ensure_ascii=False, indent=2)
    print(f"✅ 卡片 +{added_c}（总数 {len(kb['cards'])}） 题目 +{added_q}（总数 {len(kb['quizzes'])}）")

if __name__ == '__main__':
    main()
