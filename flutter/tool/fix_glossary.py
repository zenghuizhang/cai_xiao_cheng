#!/usr/bin/env python3
"""
Fix missing glossary terms so all card glossary_terms are reachable
via the test's fuzzy matching logic (card term contains glossary term or alias).
"""
import json
from pathlib import Path

ROOT = Path('/home/mira/.session/936747575059/project/cai_xiao_cheng')
FLUTTER_JSON = ROOT / 'flutter/assets/data/knowledge_base.json'
MINI_JSON = ROOT / 'miniprogram/src/data/knowledge_base.json'

MISSING_TERMS = [
    {"term":"期货","aliases":["futures","期货合约"],"one_line":"约定未来买卖的合约","daily_analogy":"像提前定好下个月的水果价格，不管涨跌都按约定来。"},
    {"term":"合约","aliases":["contract"],"one_line":"双方约定的协议","daily_analogy":"像签租房合同，约定好价格和期限。"},
    {"term":"交割","aliases":["delivery"],"one_line":"合约到期实物交接","daily_analogy":"像网购下单后快递送到你手上。"},
    {"term":"现货","aliases":["spot"],"one_line":"现买现卖的实物","daily_analogy":"像菜市场直接买菜拿走。"},
    {"term":"套期保值","aliases":["hedging","对冲"],"one_line":"用衍生品锁定风险","daily_analogy":"像买雨伞保险，下雨了不亏。"},
    {"term":"对冲","aliases":["hedge"],"one_line":"用反向操作抵消风险","daily_analogy":"像冬天穿两件衣服，一件薄一件厚来应对气温变化。"},
    {"term":"期权","aliases":["option","options"],"one_line":"选择买或卖的权利","daily_analogy":"像交定金锁定买房权但不一定要买。"},
    {"term":"看涨期权","aliases":["call option","call"],"one_line":"有权按约定价格买入","daily_analogy":"像你付定金锁定了买价，涨价了你赚。"},
    {"term":"看跌期权","aliases":["put option","put"],"one_line":"有权按约定价格卖出","daily_analogy":"像你买了个退货权，跌价了你能按原价退。"},
    {"term":"远期合约","aliases":["forward","远期"],"one_line":"场外定制的未来合约","daily_analogy":"像你和果农私下约好下月价格。"},
    {"term":"标准化合约","aliases":["standardized contract"],"one_line":"交易所统一规格的合约","daily_analogy":"像超市预包装水果，大小品质统一。"},
    {"term":"实物交割","aliases":["physical delivery"],"one_line":"用实物完成合约","daily_analogy":"像买期货黄金最后真的拿到金条。"},
    {"term":"现金交割","aliases":["cash settlement"],"one_line":"用现金差额结算","daily_analogy":"像赌涨跌，最后只赔差价不交货。"},
    {"term":"合约到期","aliases":["expiration"],"one_line":"合约到截止日","daily_analogy":"像优惠券过期就不能用了。"},
    {"term":"保证金交易","aliases":["margin trading"],"one_line":"借钱放大交易","daily_analogy":"像买房只付首付，剩下贷款。"},
    {"term":"做空","aliases":["short","shorting"],"one_line":"先卖后买赚差价","daily_analogy":"像先借朋友的手机卖了，降价了再买回还他。"},
    {"term":"互换","aliases":["swap"],"one_line":"双方交换现金流","daily_analogy":"像你和同事互换各自擅长的活来干。"},
    {"term":"策略","aliases":["strategy"],"one_line":"一套可重复的规则","daily_analogy":"像你的菜谱，每次按步骤做。"},
    {"term":"系统化交易","aliases":["systematic trading","系统化"],"one_line":"用规则自动执行交易","daily_analogy":"像设好闹钟自动响，不用你盯。"},
    {"term":"趋势","aliases":["trend"],"one_line":"价格的持续方向","daily_analogy":"像河水往下流，顺流省力逆流费力。"},
    {"term":"均线","aliases":["moving average","MA"],"one_line":"一段时间的平均价格","daily_analogy":"像你的月均消费，看趋势不看某天。"},
    {"term":"K线","aliases":["candlestick","蜡烛图"],"one_line":"含开高低收的图表","daily_analogy":"像一天温度的最低最高和起止。"},
    {"term":"支撑位","aliases":["support","支撑"],"one_line":"价格跌了容易弹回的位","daily_analogy":"像地板，球掉到地上会弹起来。"},
    {"term":"阻力位","aliases":["resistance","阻力"],"one_line":"价格涨了容易回落的位","daily_analogy":"像天花板，球扔上去被挡住。"},
    {"term":"动量","aliases":["momentum"],"one_line":"涨的继续涨的惯性","daily_analogy":"像滚动的球有惯性，不会立刻停。"},
    {"term":"反转","aliases":["mean reversion"],"one_line":"偏离太远会回来","daily_analogy":"像橡皮筋拉太长会弹回来。"},
    {"term":"做市商","aliases":["market maker","庄家"],"one_line":"随时提供买卖报价","daily_analogy":"像二手书店老板，随时买进卖出。"},
    {"term":"长期持有","aliases":["buy and hold","持有"],"one_line":"买了不轻易卖","daily_analogy":"像种棵果树，等它年年结果。"},
    {"term":"波段操作","aliases":["swing trading","波段"],"one_line":"抓中间涨跌做差价","daily_analogy":"像在浪里冲浪，抓波浪起伏。"},
    {"term":"分批建仓","aliases":["scaling in","分批"],"one_line":"分几次逐步买入","daily_analogy":"像买水果先尝一个再买一箱。"},
    {"term":"市净率","aliases":["PB","price to book"],"one_line":"股价除以净资产","daily_analogy":"像奶茶店卖价除以桌椅设备价值。"},
    {"term":"利润表","aliases":["income statement","损益表"],"one_line":"记录收入和支出","daily_analogy":"像奶茶店的月度收支账本。"},
    {"term":"利润率","aliases":["profit margin","毛利率"],"one_line":"每元收入赚多少","daily_analogy":"像卖一杯奶茶赚的占售价的比例。"},
    {"term":"股息","aliases":["dividend","分红"],"one_line":"公司分给股东的钱","daily_analogy":"像奶茶店年底把利润分给合伙人。"},
    {"term":"回购","aliases":["buyback","股票回购"],"one_line":"公司买回自己股票","daily_analogy":"像奶茶店老板觉得店被低估了，自己买回来。"},
    {"term":"成长股","aliases":["growth stock"],"one_line":"增长快的公司股票","daily_analogy":"像一家快速开分店的奶茶店。"},
    {"term":"价值股","aliases":["value stock"],"one_line":"被低估的公司股票","daily_analogy":"像一家地段好但没被注意的老店。"},
    {"term":"竞争优势","aliases":["competitive advantage","护城河"],"one_line":"对手追不上的优势","daily_analogy":"像奶茶店有独家配方别人学不来。"},
    {"term":"品牌溢价","aliases":["brand premium"],"one_line":"因品牌多收的钱","daily_analogy":"像名牌包比普通包贵就是因为牌子。"},
    {"term":"产业链","aliases":["value chain","供应链"],"one_line":"从原料到消费者的链","daily_analogy":"像茶叶从种植到加工到卖的整条线。"},
    {"term":"议价力","aliases":["bargaining power","议价能力"],"one_line":"砍价的能力","daily_analogy":"像你是大客户，进货价就能谈更低。"},
    {"term":"经济周期","aliases":["business cycle","周期"],"one_line":"经济的繁荣衰退循环","daily_analogy":"像四季交替，有暖有冷循环往复。"},
    {"term":"货币政策","aliases":["monetary policy","利率政策"],"one_line":"央行调控利率和货币","daily_analogy":"像水龙头开关，拧大放水拧小收水。"},
    {"term":"确认偏误","aliases":["confirmation bias"],"one_line":"只看自己想看的","daily_analogy":"像只关注支持自己观点的新闻。"},
    {"term":"信息茧房","aliases":["echo chamber","回音壁"],"one_line":"只听到相同观点","daily_analogy":"像在一个群里大家想法都一样，越聊越偏。"},
    {"term":"独立判断","aliases":["independent thinking","独立思考"],"one_line":"不跟风自己做判断","daily_analogy":"像别人都买网红奶茶，你自己试了再决定。"},
    {"term":"IC","aliases":["information coefficient","信息系数"],"one_line":"因子预测准确度","daily_analogy":"像天气预报准确率，越高越好。"},
    {"term":"信息系数","aliases":["IC"],"one_line":"因子预测准确度","daily_analogy":"像天气预报准确率，越高越好。"},
    {"term":"交叉验证","aliases":["cross validation"],"one_line":"分批验证防过拟合","daily_analogy":"像考试分几套卷子轮流测，防背题。"},
    {"term":"数据泄露","aliases":["data leakage","未来函数"],"one_line":"用了未来信息做预测","daily_analogy":"像考试偷看了答案再做题。"},
    {"term":"参数调优","aliases":["parameter tuning","调参"],"one_line":"找最优参数组合","daily_analogy":"像调收音机频道找最清晰的信号。"},
    {"term":"过拟合","aliases":["overfitting"],"one_line":"背答案不学原理","daily_analogy":"像只背某次考试题，换个题就考不好。"},
    {"term":"机器学习","aliases":["machine learning","ML"],"one_line":"让电脑从数据中学规律","daily_analogy":"像教小孩认猫，看多了就会了。"},
    {"term":"组合优化","aliases":["portfolio optimization"],"one_line":"找最优搭配比例","daily_analogy":"像搭配营养餐，各食材比例最优。"},
    {"term":"行业暴露","aliases":["industry exposure","行业敞口"],"one_line":"在某行业的投资占比","daily_analogy":"像你的衣服里运动装占了多少。"},
    {"term":"资金管理","aliases":["money management","仓位管理"],"one_line":"控制每笔投多少钱","daily_analogy":"像每月工资分配：房租多少吃饭多少。"},
    {"term":"仓位管理","aliases":["position sizing","仓位"],"one_line":"控制持有多少仓位","daily_analogy":"像下棋每步放多少棋子。"},
    {"term":"期望值","aliases":["expected value","EV"],"one_line":"概率加权平均结果","daily_analogy":"像掷骰子平均能掷几点。"},
    {"term":"正期望","aliases":["positive expectation","正期望值"],"one_line":"长期重复会赚钱","daily_analogy":"像赌场有优势，长期一定赚钱。"},
    {"term":"概率思维","aliases":["probabilistic thinking"],"one_line":"用概率而非确定性","daily_analogy":"像出门带伞不是确定下雨而是下雨概率高。"},
    {"term":"资金曲线","aliases":["equity curve","净值曲线"],"one_line":"账户总值随时间变化","daily_analogy":"像你的体重曲线，看长期趋势。"},
    {"term":"压力测试","aliases":["stress test"],"one_line":"模拟极端情况看损失","daily_analogy":"像汽车碰撞测试看多耐撞。"},
    {"term":"情景分析","aliases":["scenario analysis"],"one_line":"分不同情况看结果","daily_analogy":"像出门前想好晴天雨天分别怎么走。"},
    {"term":"反脆弱","aliases":["antifragile"],"one_line":"越打击越强","daily_analogy":"像疫苗让你小病后更强壮。"},
    {"term":"生存法则","aliases":["survival rule"],"one_line":"先活下来再赚钱","daily_analogy":"像登山先保命再冲顶。"},
    {"term":"交易日志","aliases":["trading journal","交易日记"],"one_line":"记录每笔交易和原因","daily_analogy":"像写日记记下每天花了什么钱。"},
    {"term":"交易纪律","aliases":["trading discipline"],"one_line":"按规则不乱来","daily_analogy":"像减肥计划说好不吃夜宵就不吃。"},
    {"term":"执行偏差","aliases":["implementation shortfall","执行"],"one_line":"计划到实际有差距","daily_analogy":"像减肥计划 vs 实际吃了多少。"},
    {"term":"冲击成本","aliases":["market impact"],"one_line":"大单推高价格","daily_analogy":"像你去菜市场要买所有西红柿，价格就被你推高了。"},
    {"term":"行为偏差","aliases":["behavioral bias","认知偏差"],"one_line":"人的不理性决策","daily_analogy":"像明知不该熬夜还是刷手机。"},
    {"term":"亏损厌恶","aliases":["loss aversion"],"one_line":"亏比赚更心痛","daily_analogy":"像丢100块的痛远大于捡100块的快乐。"},
    {"term":"情绪控制","aliases":["emotion control"],"one_line":"不让情绪影响决策","daily_analogy":"像吵架时先深呼吸再说话。"},
    {"term":"研究流程","aliases":["research process","研究"],"one_line":"系统化研究步骤","daily_analogy":"像做菜：备料→切菜→炒→尝→改进。"},
    {"term":"策略迭代","aliases":["strategy iteration"],"one_line":"不断改进策略","daily_analogy":"像手机系统不断更新升级。"},
    {"term":"可重复","aliases":["repeatable"],"one_line":"每次结果差不多","daily_analogy":"像菜谱每次做出来味道一致。"},
    {"term":"冗余","aliases":["redundancy"],"one_line":"多准备以防万一","daily_analogy":"像出门带两把钥匙防丢。"},
    {"term":"置信水平","aliases":["confidence level"],"one_line":"有多把握是对的","daily_analogy":"像你说95%确定明天会天晴。"},
    {"term":"期权定价","aliases":["option pricing"],"one_line":"算期权值多少钱","daily_analogy":"像给保险算保费，越可能赔越贵。"},
    {"term":"买入价","aliases":["bid price","bid"],"one_line":"有人愿意买的价格","daily_analogy":"像你说'这西瓜最多出5块'。"},
    {"term":"模拟盘","aliases":["paper trading","模拟交易"],"one_line":"用虚拟钱练习交易","daily_analogy":"像驾校模拟器练车不上真路。"},
]

for json_path in [FLUTTER_JSON, MINI_JSON]:
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    existing_terms = {g['term'] for g in data['glossary']}
    existing_aliases = set()
    for g in data['glossary']:
        for a in g.get('aliases', []):
            existing_aliases.add(a)

    added = 0
    for term_entry in MISSING_TERMS:
        if term_entry['term'] not in existing_terms:
            data['glossary'].append(term_entry)
            existing_terms.add(term_entry['term'])
            added += 1

    data['glossary'].sort(key=lambda g: g['term'])

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f'{json_path.name}: added {added} glossary terms, total={len(data["glossary"])}')
