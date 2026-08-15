#!/usr/bin/env python3
"""批 2：新增卡片 C1_021~025、C2_031~035 + 新题 QZ_C1_08 + 补新词条"""
import json

KB = 'assets/data/knowledge_base.json'

NEW_TERMS = [
    {"term": "保本", "aliases": [], "one_line": "保证本金不亏损",
     "daily_analogy": "白纸黑字写好的「亏了包赔」才叫保本"},
    {"term": "避险", "aliases": [], "one_line": "市场动荡时能稳住价值",
     "daily_analogy": "暴风雨里的避风港，风浪再大船不翻"},
    {"term": "破发", "aliases": [], "one_line": "价格跌破发行价",
     "daily_analogy": "新店开业就打折，买贵了的都亏着"},
    {"term": "返还型保险", "aliases": [], "one_line": "到期返还保费的保险",
     "daily_analogy": "交出去的饭钱，几十年后退回来给你"},
    {"term": "消费型保险", "aliases": [], "one_line": "纯保障、不返还的保险",
     "daily_analogy": "买雨伞：用了就是赚到，不会退钱"},
]

NEW_CARDS = [
    # ============ C1 新增 5 张 ============
    {"id": "C1_021", "chapter": 1, "order_index": 21,
     "title": "家庭资产负债表：给家拍张财务照",
     "daily_analogy": "给身体拍X光，才能看清骨头哪里有问题。家庭的财务X光片就是资产负债表：把家里所有的「会下蛋的鸡」（存款、基金、房子）和「欠着的蛋」（房贷、车贷、花呗）都列出来，相减得到净资产——这才是你真正的家底。",
     "core_knowledge": "资产负债表：左边资产（存款、投资、房产、车子现值），右边负债（房贷、车贷、信用卡、借条）。净资产=资产-负债。每月更新一次，重点看两个趋势：净资产是否增长、负债率是否下降。负债率=负债÷资产，超过50%就要警惕。",
     "illustration_note": "一张X光片形状的表格，左边列资产右边列负债，中间一个天平",
     "glossary_terms": ["资产", "负债", "净资产"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C1_08"},
    {"id": "C1_022", "chapter": 1, "order_index": 22,
     "title": "谁最怕通胀：存钱的人和老人",
     "daily_analogy": "通胀像一场偷偷下的大雨：有伞的（有房有资产、工资会涨的人）淋不着，没伞的（只靠存款和养老金的人）淋个透。退休老人的养老金涨得慢、存款利息跑不赢物价，是最怕这场雨的人——所以年轻人的任务，是提前给自己撑把伞。",
     "core_knowledge": "通胀对两类人伤害最大：①持有大量现金/存款的人——名义不变、购买力缩水；②靠固定收入生活的人（退休老人、低薪者）——收入不涨但物价涨。理解这一点，就明白为什么「把钱存银行」不是终点：至少要配置能长期跑赢通胀的资产。",
     "illustration_note": "大雨中，一个撑伞的人（标着资产）和一个没伞的老人（标着存款），雨点变成下降的购买力箭头",
     "glossary_terms": ["通货膨胀", "购买力"],
     "points": 10, "difficulty": 1,
     "related_quiz_id": "QZ_C1_01"},
    {"id": "C1_023", "chapter": 1, "order_index": 23,
     "title": "工资跑不赢通胀的真相",
     "daily_analogy": "老板给你加薪3%，你挺高兴；可这一年物价涨了5%——你的「幸福增量」其实是负数：工资多了，能买到的东西反而少了。这就是为什么年年涨薪、却感觉越来越穷：涨薪要跑赢通胀，才叫真涨薪。",
     "core_knowledge": "判断工资是否真涨，要看「实际工资=名义工资涨幅-通胀率」。名义+3%、通胀5%，实际是-2%。这也解释了为什么只靠工资积累财富很难：收入增速跑不赢通胀时，储蓄本身就在贬值。抗通胀的主力永远是「让钱生钱」的资产配置，而不是等加薪。",
     "illustration_note": "工资条上「+3%」的箭头，被旁边一个更大的「物价+5%」箭头追上并反超",
     "glossary_terms": ["实际收益", "购买力"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C1_04"},
    {"id": "C1_024", "chapter": 1, "order_index": 24,
     "title": "收益三要素：本金、利率、时间",
     "daily_analogy": "滚雪球要三样东西：雪够多（本金）、坡够滑（利率）、路够长（时间）。雪多坡滑但路只有一米，滚不出大雪球；路够长，小雪球也能滚成大雪球。大多数人盯着「利率」找高收益产品，却忘了「时间」才是最公平、最便宜的那个要素。",
     "core_knowledge": "终值=本金×(1+利率)^时间。三个变量里：本金靠储蓄率，利率靠选择（别追高），时间靠「早开始+拿得住」。30岁开始每月1000和40岁开始，同样到60岁，前者多出近一倍——时间无法用本金和利率完全替代。",
     "illustration_note": "三个雪球要素图标：一捧雪、一个斜坡、一条长长的路，路的长度被重点标注",
     "glossary_terms": ["本金", "年化收益率", "复利"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C1_05"},
    {"id": "C1_025", "chapter": 1, "order_index": 25,
     "title": "本金安全第一：先想「亏多少」",
     "daily_analogy": "过马路先看车，不是先想怎么跑得快。投资也一样：动手之前，先回答「最坏情况我亏得起吗」。亏掉50%要涨100%才能回本——所以「不亏大钱」永远是新手的第一课，比「多赚点」重要得多。",
     "core_knowledge": "投资决策顺序：先定「最大可接受亏损」，再选匹配的产品。能承受全部亏损才碰高风险；只能承受小亏就选稳健工具。一个简单的风控习惯：任何投资动手前，把「如果亏掉这笔钱的50%」写下来，看自己能不能笑着继续生活。",
     "illustration_note": "红绿灯前，一个人先看「亏多少」的警示牌再迈步，牌子上画着-50%",
     "glossary_terms": ["风险", "保本"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C1_04"},
    # ============ C2 新增 5 张 ============
    {"id": "C2_031", "chapter": 2, "order_index": 31,
     "title": "黄金：保值还是收藏",
     "daily_analogy": "黄金像家里的老棉袄：平时压箱底占地方，地震（市场崩盘）时披上能保命。它的性格是「不乱涨也不乱跌」，但也不怎么涨——长期看黄金的回报常跑不赢股票。所以它适合当「保险柜里的一小块」，不适合当「存钱的主力」。",
     "core_knowledge": "黄金的作用：①避险——市场恐慌时相对抗跌；②对冲通胀——长期跟随物价；③零信用风险。缺点：不产生利息和分红，长期收益依赖价格涨跌，且波动不小。配置比例建议5%-10%，通过黄金ETF或金条持有，别买「金首饰」（加工费吃掉收益）。",
     "illustration_note": "一个保险柜里放着金条，旁边一只股票图表，金条旁边画着「避风港」小旗",
     "glossary_terms": ["避险", "通货膨胀"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C2_05"},
    {"id": "C2_032", "chapter": 2, "order_index": 32,
     "title": "可转债与新债申购：打新的真相",
     "daily_analogy": "可转债是「一张会变魔术的借条」：平时它是债，到期还本付息；可公司股价涨了，它能变成股票跟着涨。打新债就是抽签买新发行的可转债——听起来白捡，但别忘了：它可能破发，中签也可能亏钱，只是平均来看胜率高而已。",
     "core_knowledge": "可转债=债券+看涨期权：下有保底（债性），上不封顶（股性）。打新债（申购新发行的可转债）过去中签率高、破发率低，但2022年后破发常态化，需看正股质量。新手策略：只打基本面好的、上市当天择机卖，不长期持有——别把可转债当「无风险套利」。",
     "illustration_note": "一张借条上贴着股票走势的小标签，标签写着「可转股票」",
     "glossary_terms": ["可转债", "破发"],
     "points": 20, "difficulty": 3,
     "related_quiz_id": "QZ_C2_03"},
    {"id": "C2_033", "chapter": 2, "order_index": 33,
     "title": "场外基金 vs 场内基金",
     "daily_analogy": "同样买菜，有人去菜市场现买现卖（场内，价格实时），有人网购等晚上统一送货（场外，按收盘价成交）。菜市场的好处是灵活、手续费低，但你要会看实时价格；网购省心，还有自动定投功能——各有各的好，看你要什么。",
     "core_knowledge": "场内（ETF/LOF）：券商账户买卖，实时价格，佣金低，可盘中操作，但不能自动定投；场外（普通基金）：平台申赎，按当日净值，有申赎费，支持自动定投。新手定投首选场外（自动扣款、省心），有经验后再考虑场内（低费、灵活）。",
     "illustration_note": "左右对比图：左边菜市场实时电子屏，右边手机APP下单界面，中间一个「自动定投」开关",
     "glossary_terms": ["申购", "赎回", "费率"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C2_07"},
    {"id": "C2_034", "chapter": 2, "order_index": 34,
     "title": "保险避坑：返还型 vs 消费型",
     "daily_analogy": "同样是买雨伞：消费型是「30块买把伞，下雨用，用不上也不退钱」；返还型是「300块买把伞，30年后伞还给你、钱也退给你」——听着很划算？多出的270块，保险公司拿去投资了30年，退给你的其实是你自己多交的钱。",
     "core_knowledge": "返还型保险的本质：保费=纯保障成本+储蓄投资。多交的钱保险公司拿走投资，到期返还「保额」或「保费」，长期收益通常跑不赢自己定投。对多数家庭，消费型（定期寿险、百万医疗险）+ 自己定投的组合，保障更强、成本更低。买保险先看保障，再看返还。",
     "illustration_note": "两把伞并排：一把30块标「消费型」，一把300块标「返还型」，返还款里画着「你自己的钱」",
     "glossary_terms": ["返还型保险", "消费型保险"],
     "points": 20, "difficulty": 3,
     "related_quiz_id": "QZ_C2_04"},
    {"id": "C2_035", "chapter": 2, "order_index": 35,
     "title": "看不懂的别碰：结构化产品与私募",
     "daily_analogy": "菜单上有一道菜，服务员说「配料复杂，但保证好吃」——你敢点吗？投资也一样：结构化产品、私募基金这些「配料复杂」的东西，卖的人滔滔不绝，你却说不清钱拿去干了什么。原则就一条：讲不清的，不买；看不懂的，别碰。",
     "core_knowledge": "结构化产品（挂钩衍生品的收益凭证）可能带杠杆和复杂的敲入敲出条款；私募门槛100万，信息披露少、流动性差。它们不是不好，而是「需要专业能力才能评估」。对普通人的铁律：产品结构超过三句话讲不清、条款里出现陌生名词，一律视为高风险。",
     "illustration_note": "菜单上一道菜写着「结构复杂·需要解释」，旁边一个问号，客人摆手离开",
     "glossary_terms": ["私募", "杠杆"],
     "points": 20, "difficulty": 3,
     "related_quiz_id": "QZ_C2_05"},
]

NEW_QUIZZES = [
    {"id": "QZ_C1_08", "chapter_id": "C1", "order_index": 8,
     "question": "净资产的计算方式是？",
     "options": ["资产+负债", "资产-负债", "收入-支出", "存款×利率"],
     "answer_index": 1,
     "explanation": "净资产=资产-负债，是真正属于你的家底。",
     "right_reply": "对！资产减负债，剩下的才是你的。",
     "wrong_reply": "净资产=资产-负债——房子值500万但欠贷400万，净资产只有100万。",
     "points": 20},
]

def main():
    with open(KB, encoding='utf-8') as f:
        kb = json.load(f)
    existing = {g['term'] for g in kb['glossary']}
    added_t = 0
    for t in NEW_TERMS:
        if t['term'] in existing:
            print(f"SKIP 词条已存在: {t['term']}"); continue
        kb['glossary'].append(t); existing.add(t['term']); added_t += 1

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
    print(f"✅ 词条+{added_t} 卡片+{added_c} 题目+{added_q} | 总数: 词条{len(kb['glossary'])} 卡{len(kb['cards'])} 题{len(kb['quizzes'])}")

if __name__ == '__main__':
    main()
