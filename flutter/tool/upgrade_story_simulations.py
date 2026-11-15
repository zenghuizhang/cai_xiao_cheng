#!/usr/bin/env python3
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path('/home/mira/.session/936747575059/project/cai_xiao_cheng')
TARGETS = [
    ROOT / 'flutter/assets/data/knowledge_base.json',
    ROOT / 'miniprogram/src/data/knowledge_base.json',
]

STORY_SIMS = {
    'SIM15': {
        'story_rounds': [
            {
                'id': 'R1',
                'title': '第1回合 · 年终奖到账',
                'background': '2 万年终奖刚到账，你第一次觉得自己“终于有点本金了”。这笔钱 2 年内大概率用不到，但你又怕一碰就亏。第一步你准备怎么放？',
                'options': [
                    {'key': 'A', 'text': '全部继续躺活期，先看着安心', 'feedback': '你获得了很强的“数字安全感”，但这笔钱实际上没有开始工作。', 'score_delta': 0, 'emoji': '💤'},
                    {'key': 'B', 'text': '先放进货基/短债，保留流动性再继续学', 'feedback': '你没有急着冲收益，而是先让钱动起来，同时保留随时可用的弹性。', 'score_delta': 2, 'emoji': '💧'},
                    {'key': 'C', 'text': '直接买朋友推荐的高收益产品', 'feedback': '你跳过了“看懂”这一步，把安全感交给了宣传页和别人一句话。', 'score_delta': -1, 'emoji': '🎯'},
                ],
            },
            {
                'id': 'R2',
                'title': '第2回合 · 生活突然来事',
                'background': '两个月后，手机坏了，房东又通知续租要多交一笔钱。你突然发现，所谓“长期闲钱”，不一定真的那么闲。现在你会怎么处理？',
                'options': [
                    {'key': 'A', 'text': '直接刷信用卡，先把现金留着', 'feedback': '你保住了账面现金，但把短期问题往后滚成了利息压力。', 'score_delta': 0, 'emoji': '💳'},
                    {'key': 'B', 'text': '优先从流动性好的那部分钱里解决', 'feedback': '你感受到“应急金/流动性”不是保守，而是给人生留缓冲。', 'score_delta': 2, 'emoji': '🧯'},
                    {'key': 'C', 'text': '不甘心卖掉高收益产品，继续硬扛', 'feedback': '你把一个简单生活问题，拖成了资金和情绪双重压力。', 'score_delta': -1, 'emoji': '🪤'},
                ],
            },
            {
                'id': 'R3',
                'title': '第3回合 · 同事开始晒收益',
                'background': '公司里有人晒出一个月赚几千块的截图，你一下子又觉得自己太慢了。面对“别人都在赚”的刺激，你下一步怎么做？',
                'options': [
                    {'key': 'A', 'text': '忍不住跟风，拿剩下的钱去追热点', 'feedback': '你把原本不错的起步节奏，重新拉回了情绪驱动。', 'score_delta': -1, 'emoji': '🔥'},
                    {'key': 'B', 'text': '继续学习，只拿极小金额做体验', 'feedback': '你既没有假装自己完全不心动，也没有让好奇心直接接管本金。', 'score_delta': 2, 'emoji': '🌱'},
                    {'key': 'C', 'text': '决定以后再说，先把钱彻底放着不动', 'feedback': '你回避了短期情绪，但也把建立投资习惯的机会往后推了。', 'score_delta': 1, 'emoji': '⏳'},
                ],
            },
        ],
        'story_endings': [
            {'id': 'GOOD', 'min_score': 5, 'max_score': 6, 'title': '结局：你开始学会给钱分工', 'outcome': '你没有靠一次神操作暴富，但你搭好了最重要的地基：流动性、应急意识、学习节奏和小额试错。对新手来说，这比“赚快钱”值钱得多。', 'pnl_pct': 9, 'emoji': '🏡', 'takeaway': '理财启蒙的第一目标不是冲收益，而是先建立“钱有分工”的底层习惯。'},
            {'id': 'MID', 'min_score': 2, 'max_score': 4, 'title': '结局：方向没错，但节奏还不稳', 'outcome': '你开始意识到现金、应急和投资是三件不同的事，但仍会被外界收益刺激带着走。再往前一步，你需要的是更稳定的执行节奏。', 'pnl_pct': 3, 'emoji': '🚶', 'takeaway': '新手最大的升级，不是知道更多术语，而是被刺激时还能守住节奏。'},
            {'id': 'BAD', 'min_score': -99, 'max_score': 1, 'title': '结局：你不是输给收益率，而是输给没想清楚', 'outcome': '你的每一步都很像“正常反应”：怕亏、怕慢、怕错过。但这些情绪叠在一起，就足以让第一笔本金变成第一堂高价学费。', 'pnl_pct': -8, 'emoji': '🌪️', 'takeaway': '没有分工、没有缓冲、没有节奏时，任何收益诱惑都会被放大成风险。'},
        ],
    },
    'SIM16': {
        'story_rounds': [
            {
                'id': 'R1',
                'title': '第1回合 · 父母把钱交给你',
                'background': '父母把 20 万退休金交给你，说得很直接：别乱来，别亏。你知道这笔钱和你自己的闲钱完全不是一个难度。第一步怎么配？',
                'options': [
                    {'key': 'A', 'text': '全上权益产品，长期总会涨回来', 'feedback': '你从“长期正确”出发，但忽略了持有人未必能承受中途的大波动。', 'score_delta': -1, 'emoji': '🎢'},
                    {'key': 'B', 'text': '按用途分层：应急、稳健、少量长期配置', 'feedback': '你没有追求最刺激的方案，而是先匹配这笔钱真正的责任和用途。', 'score_delta': 2, 'emoji': '🧺'},
                    {'key': 'C', 'text': '全部定期，绝不冒任何波动', 'feedback': '你极致追求安全，但也基本把长期增值空间一并锁死了。', 'score_delta': 1, 'emoji': '🏦'},
                ],
            },
            {
                'id': 'R2',
                'title': '第2回合 · 市场突然回撤',
                'background': '三个月后，市场跌了 15%，父母开始问：“是不是亏了？要不要拿出来？”这时候，你的处理方式比收益率本身更重要。',
                'options': [
                    {'key': 'A', 'text': '嘴硬安慰：长期没事，先别问了', 'feedback': '你试图用“长期主义”压住焦虑，但没有把风险预期提前讲清楚，信任开始受损。', 'score_delta': 0, 'emoji': '😶'},
                    {'key': 'B', 'text': '把钱的分层用途和可承受波动重新解释清楚', 'feedback': '你在做的不是辩解，而是让家人知道：哪些钱会波动，哪些钱不会。', 'score_delta': 2, 'emoji': '🧠'},
                    {'key': 'C', 'text': '赶紧全卖，先把争吵止住', 'feedback': '短期上你获得了平静，但也用一次情绪化动作破坏了整个长期方案。', 'score_delta': -1, 'emoji': '🛑'},
                ],
            },
            {
                'id': 'R3',
                'title': '第3回合 · 家里突然要用钱',
                'background': '父亲临时需要一笔 5 万医疗备用金。真正检验理财方案的，往往不是上涨，而是这种说来就来的现实需求。你现在怎么办？',
                'options': [
                    {'key': 'A', 'text': '直接从原本留好的流动资金里拿', 'feedback': '方案开始发挥作用：不是每笔钱都赚钱，但关键时刻有钱可用。', 'score_delta': 2, 'emoji': '🚑'},
                    {'key': 'B', 'text': '卖掉正在下跌的权益部分凑钱', 'feedback': '你并非看错市场，而是把“应急的钱”放进了不该承受波动的位置。', 'score_delta': 0, 'emoji': '📉'},
                    {'key': 'C', 'text': '先借钱拖一下，希望市场回本再说', 'feedback': '你把本该由配置解决的问题，拖成了时间和心理双重压力。', 'score_delta': -1, 'emoji': '⏰'},
                ],
            },
        ],
        'story_endings': [
            {'id': 'GOOD', 'min_score': 5, 'max_score': 6, 'title': '结局：你守住了“家人的钱”和“家人的心态”', 'outcome': '你不是把收益率做到极致，而是把责任匹配做对了：有钱可用、有风险解释、有长期空间。对家庭理财来说，这就是高级答案。', 'pnl_pct': 7, 'emoji': '🏠', 'takeaway': '给家人理财，收益只是结果，匹配风险承受力才是起点。'},
            {'id': 'MID', 'min_score': 2, 'max_score': 4, 'title': '结局：方案能用，但还有“责任盲区”', 'outcome': '你知道不能乱来，也做了一些分配，但在波动和突发需求面前，仍暴露出流动性和沟通准备不足的问题。', 'pnl_pct': 3, 'emoji': '🪜', 'takeaway': '家庭理财不只是资产配置，也是预期管理和现金流设计。'},
            {'id': 'BAD', 'min_score': -99, 'max_score': 1, 'title': '结局：你把“家人的钱”按“自己的胆量”在管', 'outcome': '看似每一步都讲得通，但风险真正来临时，方案开始露底：有人睡不着、有人临时用钱、有人被迫割肉。真正错的不是市场，是错配。', 'pnl_pct': -12, 'emoji': '🌧️', 'takeaway': '资金的主人是谁、用途是什么，决定了配置边界。'},
        ],
    },
    'SIM17': {
        'story_rounds': [
            {
                'id': 'R1',
                'title': '第1回合 · 加薪了，手更痒了',
                'background': '你每月可投资金额从 1000 提到 3000，恰好市场也涨得火热。你知道“提额”是好事，但怎么提，决定了这次加薪是变成资产，还是变成情绪燃料。',
                'options': [
                    {'key': 'A', 'text': '立刻把新增 2000 全追进最热基金', 'feedback': '你把收入增长和市场兴奋同时放大，节奏一下子变得很激进。', 'score_delta': -1, 'emoji': '🔥'},
                    {'key': 'B', 'text': '按季度逐步提额，让计划跟上收入', 'feedback': '你让定投升级，但没有让情绪先升级。', 'score_delta': 2, 'emoji': '📈'},
                    {'key': 'C', 'text': '完全不提额，等以后再说', 'feedback': '你避免了短期不适，但也错过了最容易积累本金的阶段。', 'score_delta': 1, 'emoji': '🍃'},
                ],
            },
            {
                'id': 'R2',
                'title': '第2回合 · 市场回撤 20%',
                'background': '提额 3 个月后，市场突然跌了 20%。同事开始沉默，之前的“牛回速归”也没人提了。面对回撤，你怎么调整？',
                'options': [
                    {'key': 'A', 'text': '后悔提额，立刻把新增部分停掉', 'feedback': '你把“高位买入的不舒服”翻译成了“计划错了”，情绪开始接管纪律。', 'score_delta': -1, 'emoji': '😰'},
                    {'key': 'B', 'text': '保持现有提额方案，不因为涨跌改节奏', 'feedback': '你把提额建立在收入能力上，而不是建立在市场心情上。', 'score_delta': 2, 'emoji': '🧱'},
                    {'key': 'C', 'text': '咬牙继续，但每天盯盘反复怀疑', 'feedback': '你形式上还在执行，心理上却已经被波动拖着走。', 'score_delta': 0, 'emoji': '👀'},
                ],
            },
            {
                'id': 'R3',
                'title': '第3回合 · 年底又拿到一笔奖金',
                'background': '年底你又拿到 1 万奖金。经过这段涨跌后，你对自己的风险承受能力有了更真实的认识。现在你会如何处理新增资金？',
                'options': [
                    {'key': 'A', 'text': '继续按计划分批放进去', 'feedback': '你开始把“有钱就冲动”的反应，训练成“有钱也按计划”。', 'score_delta': 2, 'emoji': '🗓️'},
                    {'key': 'B', 'text': '一次性梭哈，想把回撤阶段补回来', 'feedback': '这不是提效，而是在用奖金给之前的情绪买单。', 'score_delta': -1, 'emoji': '🎲'},
                    {'key': 'C', 'text': '一半生活，一半按计划投入', 'feedback': '你没有把理财变成苦行僧，也没有把全部新增收入都消费掉。', 'score_delta': 1, 'emoji': '⚖️'},
                ],
            },
        ],
        'story_endings': [
            {'id': 'GOOD', 'min_score': 5, 'max_score': 6, 'title': '结局：你把加薪变成了长期资产能力', 'outcome': '你最大的进步不是“赚得更多”，而是让投入节奏开始跟收入能力绑定，而不是跟市场涨跌绑定。', 'pnl_pct': 13, 'emoji': '🌳', 'takeaway': '定投升级的本质，不是更猛，而是更稳、更久、更可持续。'},
            {'id': 'MID', 'min_score': 2, 'max_score': 4, 'title': '结局：你愿意长期，但还会被市场情绪拽一下', 'outcome': '你已经知道提额是对的，但在回撤和奖金面前，仍容易临时改动作。下一步不是学更多，而是把计划写得更清楚。', 'pnl_pct': 5, 'emoji': '🪴', 'takeaway': '收入增长是加分项，执行稳定才是复利发动机。'},
            {'id': 'BAD', 'min_score': -99, 'max_score': 1, 'title': '结局：加薪放大了本金，也放大了情绪', 'outcome': '你不是没钱投，而是每次一有新增现金，就更容易追热、后悔、补救。收入上来了，体系却没同步升级。', 'pnl_pct': -6, 'emoji': '🌪️', 'takeaway': '可投资现金变多时，更需要计划，而不是更需要刺激。'},
        ],
    },
    'SIM19': {
        'story_rounds': [
            {
                'id': 'R1',
                'title': '第1回合 · 老同学来私聊',
                'background': '老同学说自己跟着“机构老师”做量化，群里收益很稳，还强调“不是普通骗局，我们有模型”。你第一反应怎么处理？',
                'options': [
                    {'key': 'A', 'text': '先进群看看，反正看看不要钱', 'feedback': '你给了对方继续影响你的入口，接下来他们最擅长的就是慢慢降低你的警惕。', 'score_delta': 0, 'emoji': '👥'},
                    {'key': 'B', 'text': '先问牌照、资金托管、主体信息', 'feedback': '你没有被“量化”两个字唬住，而是直接问最关键的底层问题。', 'score_delta': 2, 'emoji': '🔎'},
                    {'key': 'C', 'text': '听到高收益就心动，直接准备小试一笔', 'feedback': '你把“试试看”想得很轻，但很多坑就是靠这一步把人拉进来的。', 'score_delta': -1, 'emoji': '🪤'},
                ],
            },
            {
                'id': 'R2',
                'title': '第2回合 · 群里开始晒收益',
                'background': '几天后，群里有人晒出连续盈利截图，老师还说“今天有内测名额，只带 10 个人”。时间压力、从众压力、收益刺激同时上来了。你会怎么做？',
                'options': [
                    {'key': 'A', 'text': '先转一小笔，验证一下再说', 'feedback': '你以为自己在控制风险，实际上是在给对方一个继续诱导和沉没成本绑定你的机会。', 'score_delta': -1, 'emoji': '💸'},
                    {'key': 'B', 'text': '继续查信息，越催越不急', 'feedback': '你意识到“催你快一点”，本身就是风险信号。', 'score_delta': 2, 'emoji': '🧠'},
                    {'key': 'C', 'text': '虽然不转钱，但开始天天看群消息', 'feedback': '钱还没出去，但注意力和情绪已经开始被他们的节奏带着走。', 'score_delta': 0, 'emoji': '📱'},
                ],
            },
            {
                'id': 'R3',
                'title': '第3回合 · 提现前要先补税/拉人',
                'background': '这时群里有人说提现前还要先补税、升级会员，拉朋友进群还能返利。骗局的脸已经基本露出来了。你最后一步怎么做？',
                'options': [
                    {'key': 'A', 'text': '彻底退出，并提醒身边人别碰', 'feedback': '你不仅止损了自己，还把风险信息往外传了一步。', 'score_delta': 2, 'emoji': '🛡️'},
                    {'key': 'B', 'text': '自己退了，但懒得提醒别人', 'feedback': '你保护了自己，但也把这个坑留给了下一个毫无防备的人。', 'score_delta': 1, 'emoji': '🚪'},
                    {'key': 'C', 'text': '想着已经快识破了，不如最后再试一次提现', 'feedback': '很多人不是被骗在第一步，而是被骗在“都到这了，再试试”这一步。', 'score_delta': -1, 'emoji': '🌀'},
                ],
            },
        ],
        'story_endings': [
            {'id': 'GOOD', 'min_score': 5, 'max_score': 6, 'title': '结局：你把骗局挡在了“心动”之前', 'outcome': '你不是靠运气躲开，而是靠正确的检查顺序：先查底层、再看动机、最后识别催促和拉人头。', 'pnl_pct': 0, 'emoji': '🛡️', 'takeaway': '防骗能力，本质上是一套先查什么、后信什么的流程。'},
            {'id': 'MID', 'min_score': 2, 'max_score': 4, 'title': '结局：你躲开了坑，但差点被“试试看”拖进去', 'outcome': '你没有真正转大钱，但也确实被收益截图和时间压力影响过。下次更重要的是，把警惕提前到第一步。', 'pnl_pct': 0, 'emoji': '🚧', 'takeaway': '骗局最擅长利用的，不是贪心本身，而是“先试一点没关系”。'},
            {'id': 'BAD', 'min_score': -99, 'max_score': 1, 'title': '结局：你不是不聪明，只是被套路按顺序击中了', 'outcome': '同学关系、群体氛围、收益截图、限时名额、补税提现……每一步都像“再看一下”，但叠起来就足够让人中招。', 'pnl_pct': -35, 'emoji': '🕳️', 'takeaway': '面对骗局时，最危险的不是一次贪心，而是一连串“都看到这了”的妥协。'},
        ],
    },
    'SIM20': {
        'story_rounds': [
            {
                'id': 'R1',
                'title': '第1回合 · 财报出来了',
                'background': '公司营收增长 30%，用户数创新高，但利润下滑、全年指引也被下调，盘前股价已经跌了 12%。第一眼你先盯什么？',
                'options': [
                    {'key': 'A', 'text': '只看营收高增长，觉得市场错杀', 'feedback': '你抓住了一个亮点，但还没看清为什么市场会用更低价格给它估值。', 'score_delta': 0, 'emoji': '📦'},
                    {'key': 'B', 'text': '拆开看利润、现金流和指引变化', 'feedback': '你没有急着给结论，而是先判断：问题是短期投入，还是结构恶化。', 'score_delta': 2, 'emoji': '🧠'},
                    {'key': 'C', 'text': '一看到暴跌就想先跑，别研究了', 'feedback': '你用价格替代了研究，用情绪替代了分析。', 'score_delta': -1, 'emoji': '🏃'},
                ],
            },
            {
                'id': 'R2',
                'title': '第2回合 · 管理层电话会',
                'background': '电话会里，管理层解释利润下滑是因为正在加大补贴和渠道投入，短期影响利润，但希望保住份额。你怎么继续判断？',
                'options': [
                    {'key': 'A', 'text': '只要管理层说是短期投入，我就信', 'feedback': '管理层的解释值得听，但不能代替你自己验证行业和竞争格局。', 'score_delta': 0, 'emoji': '🎤'},
                    {'key': 'B', 'text': '结合行业竞争、份额和投入效率再看', 'feedback': '你开始从“公司怎么说”走向“商业上是否站得住”。', 'score_delta': 2, 'emoji': '🔬'},
                    {'key': 'C', 'text': '越听越复杂，索性凭感觉决定', 'feedback': '复杂本来就是研究的一部分，逃开复杂，就只剩情绪可用。', 'score_delta': -1, 'emoji': '🌫️'},
                ],
            },
            {
                'id': 'R3',
                'title': '第3回合 · 一周后股价继续震荡',
                'background': '财报后一周，股价没有立刻修复，而是继续震荡。你现在需要的不是“猜明天涨跌”，而是决定自己是否真的看懂了。',
                'options': [
                    {'key': 'A', 'text': '如果逻辑仍成立，就分批观察/建仓', 'feedback': '你不是因为跌了就买，而是在确认逻辑后，给自己留出犯错空间。', 'score_delta': 2, 'emoji': '🪜'},
                    {'key': 'B', 'text': '立刻重仓抄底，赌市场会很快纠错', 'feedback': '你把研究刚建立的一点优势，又交还给了冲动。', 'score_delta': -1, 'emoji': '🎲'},
                    {'key': 'C', 'text': '继续放进观察名单，不急着出手', 'feedback': '你承认自己还没看透，这种克制本身就是研究能力的一部分。', 'score_delta': 1, 'emoji': '📒'},
                ],
            },
        ],
        'story_endings': [
            {'id': 'GOOD', 'min_score': 5, 'max_score': 6, 'title': '结局：你在看公司，不是在看 K 线发脾气', 'outcome': '你把一个“财报暴跌”的刺激场景，拆成了盈利质量、竞争格局、管理层解释和建仓节奏四件事。研究能力，就是这样长出来的。', 'pnl_pct': 12, 'emoji': '📚', 'takeaway': '股票研究不是找一个好数字，而是判断“这家公司到底发生了什么变化”。'},
            {'id': 'MID', 'min_score': 2, 'max_score': 4, 'title': '结局：你开始会分析，但还会被价格推着走', 'outcome': '你已经不完全是“涨了信、跌了怕”的状态，但在复杂信息面前，仍容易被市场情绪打断判断链路。', 'pnl_pct': 4, 'emoji': '🧭', 'takeaway': '研究的进步，常常不是知道更多，而是能把价格和逻辑分开看。'},
            {'id': 'BAD', 'min_score': -99, 'max_score': 1, 'title': '结局：你以为自己在研究，其实还是在追价格反应', 'outcome': '暴跌让你想抄底，复杂解释让你烦躁，震荡让你想重仓翻本。真正驱动你的不是财报，而是价格带来的情绪波动。', 'pnl_pct': -10, 'emoji': '🌪️', 'takeaway': '如果研究结论总跟着当天涨跌走，那还不叫研究。'},
        ],
    },
    'SIM12': {
        'story_rounds': [
            {
                'id': 'R1',
                'title': '第1回合 · 小麦开始涨价',
                'background': '你开面包店，未来 3 个月要买大量面粉。小麦价格最近波动明显，你最担心的不是赚不赚钱，而是原料一涨就把利润吃光。第一步怎么做？',
                'options': [
                    {'key': 'A', 'text': '先用一部分期货把成本锁住', 'feedback': '你没有押方向暴富，而是在给生意的利润率装安全带。', 'score_delta': 2, 'emoji': '🥖'},
                    {'key': 'B', 'text': '完全不管，赌价格不会继续涨', 'feedback': '你省掉了眼前的麻烦，但也把整个经营暴露给了价格波动。', 'score_delta': -1, 'emoji': '🎲'},
                    {'key': 'C', 'text': '干脆重仓期货，顺便多赚一把', 'feedback': '你原本只想管住成本，现在却开始被“能不能多赚”吸走注意力。', 'score_delta': 0, 'emoji': '💥'},
                ],
            },
            {
                'id': 'R2',
                'title': '第2回合 · 现货真的涨了',
                'background': '一个月后，现货价格果然上涨。门店采购成本压力上来了，但你手上的决策也开始分出高下。接下来你怎么处理？',
                'options': [
                    {'key': 'A', 'text': '把套保盈利视作经营缓冲，不额外加码', 'feedback': '你守住了“工具是为生意服务”的边界。', 'score_delta': 2, 'emoji': '🧯'},
                    {'key': 'B', 'text': '看到方向对了，再加大投机仓位', 'feedback': '最容易把套保做坏的时候，就是方向刚被市场验证的时候。', 'score_delta': -1, 'emoji': '📈'},
                    {'key': 'C', 'text': '虽然做了保护，但开始嫌赚得不够多', 'feedback': '你正在忘记最初的目标：不是赚最多，而是让生意更稳。', 'score_delta': 0, 'emoji': '😵'},
                ],
            },
            {
                'id': 'R3',
                'title': '第3回合 · 销量突然变弱',
                'background': '偏偏这时门店销量转弱，库存压力变大。你发现，经营世界从来不是只有“价格涨跌”一件事。现在你最后怎么收尾？',
                'options': [
                    {'key': 'A', 'text': '主动减掉不必要仓位，优先保现金流', 'feedback': '你把套保重新拉回经营视角：先保住店，再谈市场。', 'score_delta': 2, 'emoji': '💼'},
                    {'key': 'B', 'text': '死扛仓位，觉得总会熬过去', 'feedback': '你把“坚持”误用成了“拒绝调整”，仓位和现金流开始互相拖累。', 'score_delta': -1, 'emoji': '🧱'},
                    {'key': 'C', 'text': '临时全平，之后再说', 'feedback': '你避开了继续恶化，但也说明前面的仓位和目标并没有设计得足够清楚。', 'score_delta': 1, 'emoji': '✂️'},
                ],
            },
        ],
        'story_endings': [
            {'id': 'GOOD', 'min_score': 5, 'max_score': 6, 'title': '结局：你用期货做了“经营风控”，不是“方向赌博”', 'outcome': '你守住了一个关键边界：期货只是辅助生意，而不是取代生意。成本更稳、现金流更稳、决策也更稳。', 'pnl_pct': 8, 'emoji': '🏪', 'takeaway': '套保的成功标准，不是赚到多少，而是企业能不能更平稳地活下去。'},
            {'id': 'MID', 'min_score': 2, 'max_score': 4, 'title': '结局：你知道要保护风险，但偶尔还是会手痒', 'outcome': '你已经意识到期货可以服务经营，但一旦方向被验证，还是容易把“保护工具”变成“赚钱工具”。', 'pnl_pct': 2, 'emoji': '🪖', 'takeaway': '做套保最难的不是开仓，而是始终记得自己为什么开仓。'},
            {'id': 'BAD', 'min_score': -99, 'max_score': 1, 'title': '结局：你本来想锁成本，最后却把生意也卷进了波动', 'outcome': '从赌价格不涨，到想顺便多赚一把，再到现金流被仓位拖垮——问题不是期货，而是目标早就从“经营”变成了“押方向”。', 'pnl_pct': -18, 'emoji': '🌊', 'takeaway': '当工具的目标被改写时，风险就会开始反咬使用者。'},
        ],
    },
    'SIM23': {
        'story_rounds': [
            {
                'id': 'R1',
                'title': '第1回合 · 圣杯报告递到你面前',
                'background': '一份策略报告写着：胜率 92%、年化 35%、最大回撤 5%，而且曲线平滑得像用尺子画出来。遇到这种“太完美”的策略，你第一步怎么反应？',
                'options': [
                    {'key': 'A', 'text': '太强了，先信一半，准备上实盘', 'feedback': '你已经被结果打动，开始为它寻找合理性，而不是先找它可能哪里有坑。', 'score_delta': -1, 'emoji': '🏆'},
                    {'key': 'B', 'text': '先假设它有问题，开始做反向审计', 'feedback': '你把“看起来完美”当成了需要优先验证的红旗。', 'score_delta': 2, 'emoji': '🩺'},
                    {'key': 'C', 'text': '先把参数再调一调，看能不能更漂亮', 'feedback': '你还没搞清它是不是真的，就已经开始帮它化妆了。', 'score_delta': -1, 'emoji': '🎨'},
                ],
            },
            {
                'id': 'R2',
                'title': '第2回合 · 成本和容量浮出水面',
                'background': '你进一步发现：这个策略交易很频繁，报告里却几乎没算手续费、滑点和冲击成本，而且资金容量也说得很模糊。你现在怎么处理？',
                'options': [
                    {'key': 'A', 'text': '把摩擦成本和容量限制补进去重算', 'feedback': '你开始把“纸面策略”往“真实世界”里拽。', 'score_delta': 2, 'emoji': '🧾'},
                    {'key': 'B', 'text': '成本先不管，跑出来再说', 'feedback': '你把最可能杀死实盘的因素，先假装它不存在。', 'score_delta': -1, 'emoji': '🙈'},
                    {'key': 'C', 'text': '觉得有点复杂，先凭感觉保留乐观', 'feedback': '复杂不是问题，回避复杂才会让问题变贵。', 'score_delta': 0, 'emoji': '🌫️'},
                ],
            },
            {
                'id': 'R3',
                'title': '第3回合 · 样本外只剩普通水平',
                'background': '做完样本外测试后，策略表现变得普通：胜率降了、回撤大了、年化也不再夸张。你最后怎么决定？',
                'options': [
                    {'key': 'A', 'text': '降低预期，小仓位继续观察', 'feedback': '你接受“它也许只是个普通策略”，但普通不代表不能用。', 'score_delta': 2, 'emoji': '🔬'},
                    {'key': 'B', 'text': '不甘心，再调到好看为止', 'feedback': '你不愿接受真实结果，开始用调参和筛选把现实重新修图。', 'score_delta': -1, 'emoji': '🪄'},
                    {'key': 'C', 'text': '直接放弃，觉得既然不神就没价值', 'feedback': '你避开了风险，但也差点把“可用但不惊艳”的好策略一起丢掉。', 'score_delta': 1, 'emoji': '📦'},
                ],
            },
        ],
        'story_endings': [
            {'id': 'GOOD', 'min_score': 5, 'max_score': 6, 'title': '结局：你没有寻找圣杯，你在寻找“真实可用”', 'outcome': '你把一个极其诱人的回测故事，拆成了审计、摩擦、容量、样本外和仓位验证。量化研究真正的成熟，往往就体现在这里。', 'pnl_pct': 11, 'emoji': '🧪', 'takeaway': '研究不是帮策略证明自己伟大，而是尽可能证明它没那么容易死。'},
            {'id': 'MID', 'min_score': 2, 'max_score': 4, 'title': '结局：你开始有研究意识，但还没彻底戒掉“想要更漂亮”', 'outcome': '你已经知道完美回测要怀疑，但在成本、参数和样本外面前，仍会本能地想把结果修好看一点。', 'pnl_pct': 3, 'emoji': '🧭', 'takeaway': '量化里最贵的，不是算力，而是对“普通结果”的接受能力。'},
            {'id': 'BAD', 'min_score': -99, 'max_score': 1, 'title': '结局：你爱上了报表，不是爱上了策略', 'outcome': '当一个结果太好看时，你没有先拆它，反而先信它、调它、维护它。最后留下来的，可能只是一个历史上很美的幻觉。', 'pnl_pct': -15, 'emoji': '🎭', 'takeaway': '越像圣杯的东西，越要先怀疑它是不是镜花水月。'},
        ],
    },
    'SIM25': {
        'story_rounds': [
            {
                'id': 'R1',
                'title': '第1回合 · 连亏 5 笔',
                'background': '你的系统最近连续亏了 5 笔，每一笔都在计划内，但人已经开始不稳了。最危险的时刻不是亏损本身，而是你开始想“下一笔必须狠狠干回来”。现在怎么做？',
                'options': [
                    {'key': 'A', 'text': '下一笔加倍，想把前面都赢回来', 'feedback': '你表面上还在交易，实际上已经在和前 5 笔情绪对赌。', 'score_delta': -1, 'emoji': '🎲'},
                    {'key': 'B', 'text': '先按规则减仓，再继续执行', 'feedback': '你承认情绪正在上来，于是先把情绪可能造成的伤害降下来。', 'score_delta': 2, 'emoji': '🧘'},
                    {'key': 'C', 'text': '直接停掉，觉得自己不适合这套系统', 'feedback': '你立刻获得了情绪缓解，但也可能把统计优势停在最差的时候。', 'score_delta': 0, 'emoji': '🛑'},
                ],
            },
            {
                'id': 'R2',
                'title': '第2回合 · 第 6 笔也没让你舒服',
                'background': '第 6 笔之后，不管赚没赚，你都发现自己已经不在“平常心”里了：盯盘更勤、想法更多、睡眠更差。你现在如何处理这个状态？',
                'options': [
                    {'key': 'A', 'text': '继续硬撑，告诉自己职业选手就该扛', 'feedback': '你把“承受力”理解成“不能承认自己受影响”，风险只会继续积累。', 'score_delta': -1, 'emoji': '🧱'},
                    {'key': 'B', 'text': '做交易日志复盘，把情绪和执行拆开看', 'feedback': '你开始区分：到底是策略失效，还是自己在执行层面变形。', 'score_delta': 2, 'emoji': '📓'},
                    {'key': 'C', 'text': '去群里找别人给你信心', 'feedback': '你把本该自己消化的风险，又外包给了别人的情绪和观点。', 'score_delta': 0, 'emoji': '📣'},
                ],
            },
            {
                'id': 'R3',
                'title': '第3回合 · 下周一开盘前',
                'background': '休息一晚后，市场又要开盘了。你终于明白，风控不是一个按钮，而是一套让你在脆弱时也能继续活着的流程。最后这一步你怎么走？',
                'options': [
                    {'key': 'A', 'text': '恢复到书面规则：仓位、止损、暂停条件都照表执行', 'feedback': '你把自己从“靠感觉扛”拉回到了“靠流程活”。', 'score_delta': 2, 'emoji': '📋'},
                    {'key': 'B', 'text': '觉得自己已经想通，先正常满仓试一把', 'feedback': '最容易出事的时候，往往就是你以为自己已经恢复的时候。', 'score_delta': -1, 'emoji': '⚠️'},
                    {'key': 'C', 'text': '再休息一周，同时保留观察和复盘', 'feedback': '你没有强迫自己立刻证明“我没问题”，这也是成熟的一部分。', 'score_delta': 1, 'emoji': '🕰️'},
                ],
            },
        ],
        'story_endings': [
            {'id': 'GOOD', 'min_score': 5, 'max_score': 6, 'title': '结局：你没有赢回每一笔，但你保住了系统和自己', 'outcome': '你做对的，不是神奇翻盘，而是在最容易乱来的阶段，用减仓、日志和书面规则保住了执行能力。长期赢家常常就赢在这里。', 'pnl_pct': 6, 'emoji': '🛡️', 'takeaway': '真正的风控，不是从不怕，而是怕的时候还有流程可以依靠。'},
            {'id': 'MID', 'min_score': 2, 'max_score': 4, 'title': '结局：你知道风控重要，但还会在脆弱时想证明自己', 'outcome': '你已经开始做复盘和减仓，但在某些节点上，仍会被“我应该扛得住”这种自我要求拉回危险边缘。', 'pnl_pct': 1, 'emoji': '🧭', 'takeaway': '承认自己受影响，不是脆弱，而是风控开始生效的前提。'},
            {'id': 'BAD', 'min_score': -99, 'max_score': 1, 'title': '结局：你输的不是第 6 笔，而是第 1 到第 5 笔累积出来的情绪', 'outcome': '连续亏损最可怕的地方不在报表，而在它一点点改写你的节奏：想翻本、想证明、想立刻正常。等你意识到时，系统早就不是原来的系统了。', 'pnl_pct': -16, 'emoji': '🌪️', 'takeaway': '连亏阶段最大的风险，不是市场，而是你偷偷开始用情绪接管规则。'},
        ],
    },
}

def to_legacy_options(story_round):
    legacy = []
    for opt in story_round['options']:
        legacy.append({
            'key': opt['key'],
            'text': opt['text'],
            'outcome': opt['feedback'],
            'pnl_pct': 0,
            'emoji': opt['emoji'],
            'takeaway': '进入后续剧情后查看最终结局',
        })
    return legacy

for path in TARGETS:
    data = json.loads(path.read_text(encoding='utf-8'))
    sims = {s['id']: s for s in data['simulations']}
    for sim_id, story in STORY_SIMS.items():
        if sim_id not in sims:
            raise SystemExit(f'missing simulation: {sim_id}')
        sims[sim_id]['story_rounds'] = story['story_rounds']
        sims[sim_id]['story_endings'] = story['story_endings']
        sims[sim_id]['options'] = to_legacy_options(story['story_rounds'][0])
    data['simulations'] = sorted(sims.values(), key=lambda s: (s['order_index'], s['id']))
    data['meta']['updated_at'] = '2026-11-15'
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'{path.name}: story_sims={len(STORY_SIMS)} total_sims={len(data["simulations"])}')
