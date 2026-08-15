#!/usr/bin/env python3
"""批 1：新增卡片 C3_021~025、C4_021~025 + 新题 QZ_C3_06/07、QZ_C4_06/07"""
import json

KB = 'assets/data/knowledge_base.json'

NEW_CARDS = [
    # ============ C3 新增 5 张 ============
    {"id": "C3_021", "chapter": 3, "order_index": 21,
     "title": "月投还是周投：频率不影响结果",
     "daily_analogy": "浇花到底是每天浇一点，还是每周浇一次？结论是差别不大——只要总量一样，植物才不在乎你哪天下手。定投同理：按月投和按周投，长期收益几乎没区别，选个发工资日的日子，好坚持才最重要。",
     "core_knowledge": "数据上，月投与周投的长期收益差异在1%以内，主要影响是心理：周投让你「看盘更勤」，反而容易手痒。定投频率的选择标准是「好坚持」——工资日自动月扣，是大多数人最省心的方案。",
     "illustration_note": "两盆花：一盆每天浇一点，一盆每周浇一次，长势一样，旁边一个日历标着发薪日",
     "glossary_terms": ["定投", "定期定额"],
     "points": 10, "difficulty": 1,
     "related_quiz_id": "QZ_C3_04"},
    {"id": "C3_022", "chapter": 3, "order_index": 22,
     "title": "现在就是最好的开始时间",
     "daily_analogy": "种树最好的时间是十年前，其次是现在。等「跌到底了」再开始，就像等「天气完美」再出门——你永远等不到，还白白错过好几年复利。定投的美妙在于：你不需要猜起点，现在开始，市场自己给你平均价格。",
     "core_knowledge": "回测告诉我们：任何时点开始定投，长期结果差异远小于「没开始」与「开始了」的差异。等待低点的成本是时间×复利。对新手：启动比择时重要100倍，坚持比完美重要100倍。",
     "illustration_note": "日历被划掉的好几页都写着「等低点」，右下角一个小树苗终于种下",
     "glossary_terms": ["长期主义", "复利"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C3_06"},
    {"id": "C3_023", "chapter": 3, "order_index": 23,
     "title": "大跌日：定投的黄金时刻",
     "daily_analogy": "超市大减价你会冲进去囤货，市场大减价你却想割肉跑路——人性就是这么拧巴。定投不怕跌：同样的钱，大跌时买到的份额更多。跌10%时你买到的「菜」，比涨10%时便宜整整一档。",
     "core_knowledge": "定投的核心逻辑是平均成本：跌时多买份额，涨时少买，长期摊低成本。大跌不是风险而是「打折进货」。真正该做的是：继续扣款，条件允许时甚至可以适度加投——这正是定投与一次性买入最大的不同。",
     "illustration_note": "商场「全场5折」横幅下，一个人推着购物车开心进货，标签写着「指数大跌日」",
     "glossary_terms": ["波动", "纪律"],
     "points": 20, "difficulty": 3,
     "related_quiz_id": "QZ_C3_07"},
    {"id": "C3_024", "chapter": 3, "order_index": 24,
     "title": "回撤的数学：跌50%要涨100%",
     "daily_analogy": "100块跌50%变50块，50块要涨回100块需要涨100%——亏的每一分钱，都要用加倍的涨幅去还。所以新手的第一课不是「怎么赚」，而是「怎么别亏大」：控制回撤，就是保护你的复利引擎。",
     "core_knowledge": "回撤的数学：跌X%后回到原点需要涨 X/(1-X)%。跌10%要涨11%，跌30%要涨43%，跌50%要涨100%。所以资产配置的意义不是多赚，而是「跌的时候别伤筋动骨」——回撤越小，回到高点的路越短。",
     "illustration_note": "一段下坡路标着「-50%」，旁边一段更陡的上坡路标着「+100%」，小人看着发愁",
     "glossary_terms": ["回撤", "浮亏"],
     "points": 20, "difficulty": 3,
     "related_quiz_id": "QZ_C3_08"},
    {"id": "C3_025", "chapter": 3, "order_index": 25,
     "title": "目标收益率止盈法：到点就撤",
     "daily_analogy": "钓鱼高手从不追求「钓到最大那条」，而是「到点收竿」：定个目标——浮盈20%就收，收完开心回家。贪心的人总想再等一等，结果鱼又跑了。止盈不是预测顶部，是给贪婪装个刹车。",
     "core_knowledge": "目标止盈法：设定收益率（如20%），达到即赎回，落袋后重新开始定投。简单、可执行、避免「坐了趟过山车」。缺点是大牛市会卖早。更进阶的做法是分批止盈（如分3次）。新手用目标止盈比预测顶点靠谱得多。",
     "illustration_note": "一个人钓起鱼来看了一眼标着20%的刻度尺，满意地收竿回家",
     "glossary_terms": ["止盈", "目标收益率"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C3_02"},
    # ============ C4 新增 5 张 ============
    {"id": "C4_021", "chapter": 4, "order_index": 21,
     "title": "处置效应：赚了就跑，亏了死扛",
     "daily_analogy": "炒股的人常干两件矛盾的事：涨了5%就迫不及待卖掉「落袋为安」，跌了30%却死活不卖「等回本」。同样一笔钱，赚了怕失去，亏了不甘心——这就是处置效应：让利润早跑，让亏损陪睡。",
     "core_knowledge": "处置效应指人倾向于「卖出盈利、持有亏损」。心理根源是损失厌恶与「账面亏损不算真亏」的自我欺骗。破解：买入前先写下卖出条件（目标价/止损线），把「卖不卖」从情绪题变成是非题。",
     "illustration_note": "一只小兔子，看到胡萝卜苗就拔，看到杂草就留着，园丁叹气",
     "glossary_terms": ["处置效应", "浮亏"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C4_06"},
    {"id": "C4_022", "chapter": 4, "order_index": 22,
     "title": "确认偏差：只看见想看的",
     "daily_analogy": "你认定某只股票要涨，就能在新闻里找到一百条「看涨的理由」，把看跌的信息自动过滤。就像想买某牌子的车，满大街都是同款——不是它变多了，是你的眼睛开始挑食了。",
     "core_knowledge": "确认偏差：人倾向于寻找、解读、记住支持自己观点的信息，忽略相反证据。投资中危害极大——让你在错误方向上越来越自信。破解：主动找「反对自己的三个理由」，或写投资日志记录当时依据，强制自己看到反面。",
     "illustration_note": "一个戴着眼罩的人只看得到正面写着「涨」的牌子，背后写「跌」的牌子被无视",
     "glossary_terms": ["确认偏差", "噪音"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C4_02"},
    {"id": "C4_023", "chapter": 4, "order_index": 23,
     "title": "赌徒谬误：硬币没有记忆",
     "daily_analogy": "抛硬币连出10次正面，第11次是反面吗？硬币不记得刚才发生了什么，每次都是50%。可赌徒不信：连涨几天的股票「该跌了吧」——市场的涨跌也不会因为「跌够了」就反弹。",
     "core_knowledge": "赌徒谬误：误以为独立事件的概率会被历史结果影响。市场短期涨跌近似独立事件，「已经跌了很多」不等于「该涨了」。定投之所以有效，正是因为它不赌「该不该反转」，而是用固定节奏穿越不确定性。",
     "illustration_note": "一个赌徒盯着连续10个正面的硬币，第11枚在翻面——他坚信必是反面",
     "glossary_terms": ["赌徒谬误", "随机性"],
     "points": 20, "difficulty": 3,
     "related_quiz_id": "QZ_C4_07"},
    {"id": "C4_024", "chapter": 4, "order_index": 24,
     "title": "框架效应：换个说法就变判断",
     "daily_analogy": "手术成功率90%和死亡率10%是同一件事，可大多数人一听「90%存活」就敢签字，一听「10%死亡」就犹豫。基金宣传也一样：「近一年涨15%」和「近一年有23%时间在下跌」是同一个基金，说法不同，你下的决心完全不同。",
     "core_knowledge": "框架效应：同一信息的不同表述方式，会改变人的决策。投资中，商家用「收益框架」宣传，用「风险框架」回避。破解：做决定前，把信息翻译成中性语言——收益和风险都写下来再比较。",
     "illustration_note": "同一杯水，左边标「半满」，右边标「半空」，两个人的表情完全不同",
     "glossary_terms": ["框架效应", "锚定效应"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C4_03"},
    {"id": "C4_025", "chapter": 4, "order_index": 25,
     "title": "过度交易：手续费是沉默的吸血鬼",
     "daily_analogy": "频繁进出市场的人，像高速路上来回掉头——油钱（手续费）烧了不少，里程（收益）没跑多少。假设每次交易成本0.3%，一年交易40次，光费用就吃掉12%——这个「吸血鬼」不声不响，专吸手痒的人。",
     "core_knowledge": "交易成本=手续费+滑点+税。频繁交易不仅费钱，还放大情绪化决策（每笔交易都刺激多巴胺）。数据显示散户越频繁交易收益越差。破解：给每笔交易设「冷却期」（如想卖等3天再决定），或直接用自动定投物理隔绝手痒。",
     "illustration_note": "一条高速公路上，一辆车在匝道口反复掉头，油箱下面写着「手续费」在漏油",
     "glossary_terms": ["手续费", "换手率"],
     "points": 15, "difficulty": 2,
     "related_quiz_id": "QZ_C4_05"},
]

NEW_QUIZZES = [
    {"id": "QZ_C3_06", "chapter_id": "C3", "order_index": 6,
     "question": "关于「开始定投的时机」，正确的是？",
     "options": ["一定要等市场跌到最低点再开始", "任何时候开始都可以，早开始比完美择时重要", "牛市才能开始", "等攒够一大笔钱再一次性投入"],
     "answer_index": 1,
     "explanation": "等待低点的成本是时间×复利。定投的机制决定了任何时候起步都有意义。",
     "right_reply": "对！种树最好的时间是十年前，其次是现在。",
     "wrong_reply": "等最低点等于永远不开始——定投本身就是帮你穿越时点的不确定性。",
     "points": 20},
    {"id": "QZ_C3_07", "chapter_id": "C3", "order_index": 7,
     "question": "定投期间遇到市场大跌30%，正确的做法是？",
     "options": ["立即全部卖出止损", "停止扣款等企稳", "继续按计划定投（条件允许可适度加投）", "加杠杆抄底"],
     "answer_index": 2,
     "explanation": "大跌是定投的「打折进货日」，平均成本被摊低。停扣才是真亏损——错过了便宜份额。",
     "right_reply": "答对！大跌日就是定投的黄金时刻，别浪费打折机会。",
     "wrong_reply": "大跌恰恰是定投该继续的时候——停扣等于在最便宜的时候收手。",
     "points": 20},
    {"id": "QZ_C4_06", "chapter_id": "C4", "order_index": 6,
     "question": "「涨了5%就卖、跌了30%死扛」属于哪种认知偏差？",
     "options": ["赌徒谬误", "处置效应", "框架效应", "羊群效应"],
     "answer_index": 1,
     "explanation": "处置效应：卖盈利保亏损。根源是损失厌恶——账面亏损比到手亏损「没那么疼」。",
     "right_reply": "对！让利润早跑、让亏损陪睡，就是处置效应。",
     "wrong_reply": "这不是运气问题，是处置效应——卖盈利、持亏损，多数人的通病。",
     "points": 20},
    {"id": "QZ_C4_07", "chapter_id": "C4", "order_index": 7,
     "question": "抛硬币连出10次正面，第11次出现反面的概率是？",
     "options": ["接近100%，因为「该出反面了」", "50%，硬币没有记忆", "25%", "0%，肯定还是正面"],
     "answer_index": 1,
     "explanation": "独立事件互不影响。赌徒谬误是把「概率」错当成「债」——市场也一样。",
     "right_reply": "对！硬币不记得刚才发生了什么，市场也一样。",
     "wrong_reply": "硬币没有记忆——这正是赌徒谬误：别把「跌够了」当成「该涨了」。",
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
