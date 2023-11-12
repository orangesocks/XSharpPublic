﻿// Copyright (c) Terence Parr, Sam Harwell. All Rights Reserved.
// Licensed under the BSD License. See LICENSE.txt in the project root for license information.
#nullable disable
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Sharpen;

namespace Antlr4.Runtime.Atn
{
    public class ATNSerializer
    {
        public ATN atn;

        private IList<string> ruleNames;

        private IList<string> tokenNames;

        public ATNSerializer(ATN atn, IList<string> ruleNames)
        {
            this.atn = atn;
            this.ruleNames = ruleNames;
        }

        public ATNSerializer(ATN atn, IList<string> ruleNames, IList<string> tokenNames)
        {
            this.atn = atn;
            this.ruleNames = ruleNames;
            this.tokenNames = tokenNames;
        }

        /// <summary>
        /// Serialize state descriptors, edge descriptors, and decision→state map
        /// into list of ints:
        /// grammar-type, (ANTLRParser.LEXER, ...)
        /// max token type,
        /// num states,
        /// state-0-type ruleIndex, state-1-type ruleIndex, ...
        /// </summary>
        /// <remarks>
        /// Serialize state descriptors, edge descriptors, and decision→state map
        /// into list of ints:
        /// grammar-type, (ANTLRParser.LEXER, ...)
        /// max token type,
        /// num states,
        /// state-0-type ruleIndex, state-1-type ruleIndex, ... state-i-type ruleIndex optional-arg ...
        /// num rules,
        /// rule-1-start-state rule-1-args, rule-2-start-state  rule-2-args, ...
        /// (args are token type,actionIndex in lexer else 0,0)
        /// num modes,
        /// mode-0-start-state, mode-1-start-state, ... (parser has 0 modes)
        /// num sets
        /// set-0-interval-count intervals, set-1-interval-count intervals, ...
        /// num total edges,
        /// src, trg, edge-type, edge arg1, optional edge arg2 (present always), ...
        /// num decisions,
        /// decision-0-start-state, decision-1-start-state, ...
        /// Convenient to pack into unsigned shorts to make as Java string.
        /// </remarks>
        public virtual List<int> Serialize()
        {
            List<int> data = new List<int>();
            data.Add(ATNDeserializer.SerializedVersion);
            SerializeUUID(data, ATNDeserializer.SerializedUuid);
            // convert grammar type to ATN const to avoid dependence on ANTLRParser
            data.Add((int)(atn.grammarType));
            data.Add(atn.maxTokenType);
            int nedges = 0;
            IDictionary<IntervalSet, int> setIndices = new Dictionary<IntervalSet, int>();
            IList<IntervalSet> sets = new List<IntervalSet>();
            // dump states, count edges and collect sets while doing so
            List<int> nonGreedyStates = new List<int>();
            List<int> sllStates = new List<int>();
            List<int> precedenceStates = new List<int>();
            data.Add(atn.states.Count);
            foreach (ATNState s in atn.states)
            {
                if (s == null)
                {
                    // might be optimized away
                    data.Add((int)(StateType.InvalidType));
                    continue;
                }
                StateType stateType = s.StateType;
                if (s is DecisionState)
                {
                    DecisionState decisionState = (DecisionState)s;
                    if (decisionState.nonGreedy)
                    {
                        nonGreedyStates.Add(s.stateNumber);
                    }
                    if (decisionState.sll)
                    {
                        sllStates.Add(s.stateNumber);
                    }
                }
                if (s is RuleStartState && ((RuleStartState)s).isPrecedenceRule)
                {
                    precedenceStates.Add(s.stateNumber);
                }
                data.Add((int)(stateType));
                if (s.ruleIndex == -1)
                {
                    data.Add(char.MaxValue);
                }
                else
                {
                    data.Add(s.ruleIndex);
                }
                if (s.StateType == StateType.LoopEnd)
                {
                    data.Add(((LoopEndState)s).loopBackState.stateNumber);
                }
                else
                {
                    if (s is BlockStartState)
                    {
                        data.Add(((BlockStartState)s).endState.stateNumber);
                    }
                }
                if (s.StateType != StateType.RuleStop)
                {
                    // the deserializer can trivially derive these edges, so there's no need to serialize them
                    nedges += s.NumberOfTransitions;
                }
                for (int i = 0; i < s.NumberOfTransitions; i++)
                {
                    Transition t = s.Transition(i);
                    TransitionType edgeType = t.TransitionType;
                    if (edgeType == TransitionType.Set || edgeType == TransitionType.NotSet)
                    {
                        SetTransition st = (SetTransition)t;
                        if (!setIndices.ContainsKey(st.set))
                        {
                            sets.Add(st.set);
                            setIndices[st.set] = sets.Count - 1;
                        }
                    }
                }
            }
            // non-greedy states
            data.Add(nonGreedyStates.Count);
            for (int i_1 = 0; i_1 < nonGreedyStates.Count; i_1++)
            {
                data.Add(nonGreedyStates[i_1]);
            }
            // SLL decisions
            data.Add(sllStates.Count);
            for (int i_2 = 0; i_2 < sllStates.Count; i_2++)
            {
                data.Add(sllStates[i_2]);
            }
            // precedence states
            data.Add(precedenceStates.Count);
            for (int i_3 = 0; i_3 < precedenceStates.Count; i_3++)
            {
                data.Add(precedenceStates[i_3]);
            }
            int nrules = atn.ruleToStartState.Length;
            data.Add(nrules);
            for (int r = 0; r < nrules; r++)
            {
                ATNState ruleStartState = atn.ruleToStartState[r];
                data.Add(ruleStartState.stateNumber);
                bool leftFactored = ruleNames[ruleStartState.ruleIndex].IndexOf(ATNSimulator.RuleVariantDelimiter) >= 0;
                data.Add(leftFactored ? 1 : 0);
                if (atn.grammarType == ATNType.Lexer)
                {
                    if (atn.ruleToTokenType[r] == TokenConstants.Eof)
                    {
                        data.Add(char.MaxValue);
                    }
                    else
                    {
                        data.Add(atn.ruleToTokenType[r]);
                    }
                }
            }
            int nmodes = atn.modeToStartState.Count;
            data.Add(nmodes);
            if (nmodes > 0)
            {
                foreach (ATNState modeStartState in atn.modeToStartState)
                {
                    data.Add(modeStartState.stateNumber);
                }
            }
            int nsets = sets.Count;
            data.Add(nsets);
            foreach (IntervalSet set in sets)
            {
                bool containsEof = set.Contains(TokenConstants.Eof);
                if (containsEof && set.GetIntervals()[0].b == TokenConstants.Eof)
                {
                    data.Add(set.GetIntervals().Count - 1);
                }
                else
                {
                    data.Add(set.GetIntervals().Count);
                }
                data.Add(containsEof ? 1 : 0);
                foreach (Interval I in set.GetIntervals())
                {
                    if (I.a == TokenConstants.Eof)
                    {
                        if (I.b == TokenConstants.Eof)
                        {
                            continue;
                        }
                        else
                        {
                            data.Add(0);
                        }
                    }
                    else
                    {
                        data.Add(I.a);
                    }
                    data.Add(I.b);
                }
            }
            data.Add(nedges);
            foreach (ATNState s_1 in atn.states)
            {
                if (s_1 == null)
                {
                    // might be optimized away
                    continue;
                }
                if (s_1.StateType == StateType.RuleStop)
                {
                    continue;
                }
                for (int i = 0; i < s_1.NumberOfTransitions; i++)
                {
                    Transition t = s_1.Transition(i);
                    if (atn.states[t.target.stateNumber] == null)
                    {
                        throw new InvalidOperationException("Cannot serialize a transition to a removed state.");
                    }
                    int src = s_1.stateNumber;
                    int trg = t.target.stateNumber;
                    TransitionType edgeType = t.TransitionType;
                    int arg1 = 0;
                    int arg2 = 0;
                    int arg3 = 0;
                    switch (edgeType)
                    {
                        case TransitionType.Rule:
                        {
                            trg = ((RuleTransition)t).followState.stateNumber;
                            arg1 = ((RuleTransition)t).target.stateNumber;
                            arg2 = ((RuleTransition)t).ruleIndex;
                            arg3 = ((RuleTransition)t).precedence;
                            break;
                        }

                        case TransitionType.Precedence:
                        {
                            PrecedencePredicateTransition ppt = (PrecedencePredicateTransition)t;
                            arg1 = ppt.precedence;
                            break;
                        }

                        case TransitionType.Predicate:
                        {
                            PredicateTransition pt = (PredicateTransition)t;
                            arg1 = pt.ruleIndex;
                            arg2 = pt.predIndex;
                            arg3 = pt.isCtxDependent ? 1 : 0;
                            break;
                        }

                        case TransitionType.Range:
                        {
                            arg1 = ((RangeTransition)t).from;
                            arg2 = ((RangeTransition)t).to;
                            if (arg1 == TokenConstants.Eof)
                            {
                                arg1 = 0;
                                arg3 = 1;
                            }
                            break;
                        }

                        case TransitionType.Atom:
                        {
                            arg1 = ((AtomTransition)t).label;
                            if (arg1 == TokenConstants.Eof)
                            {
                                arg1 = 0;
                                arg3 = 1;
                            }
                            break;
                        }

                        case TransitionType.Action:
                        {
                            ActionTransition at = (ActionTransition)t;
                            arg1 = at.ruleIndex;
                            arg2 = at.actionIndex;
                            if (arg2 == -1)
                            {
                                arg2 = unchecked((int)(0xFFFF));
                            }
                            arg3 = at.isCtxDependent ? 1 : 0;
                            break;
                        }

                        case TransitionType.Set:
                        {
                            arg1 = setIndices[((SetTransition)t).set];
                            break;
                        }

                        case TransitionType.NotSet:
                        {
                            arg1 = setIndices[((SetTransition)t).set];
                            break;
                        }

                        case TransitionType.Wildcard:
                        {
                            break;
                        }
                    }
                    data.Add(src);
                    data.Add(trg);
                    data.Add((int)(edgeType));
                    data.Add(arg1);
                    data.Add(arg2);
                    data.Add(arg3);
                }
            }
            int ndecisions = atn.decisionToState.Count;
            data.Add(ndecisions);
            foreach (DecisionState decStartState in atn.decisionToState)
            {
                data.Add(decStartState.stateNumber);
            }
            //
            // LEXER ACTIONS
            //
            if (atn.grammarType == ATNType.Lexer)
            {
                data.Add(atn.lexerActions.Length);
                foreach (ILexerAction action in atn.lexerActions)
                {
                    data.Add((int)(action.ActionType));
                    switch (action.ActionType)
                    {
                        case LexerActionType.Channel:
                        {
                            int channel = ((LexerChannelAction)action).Channel;
                            data.Add(channel != -1 ? channel : unchecked((int)(0xFFFF)));
                            data.Add(0);
                            break;
                        }

                        case LexerActionType.Custom:
                        {
                            int ruleIndex = ((LexerCustomAction)action).RuleIndex;
                            int actionIndex = ((LexerCustomAction)action).ActionIndex;
                            data.Add(ruleIndex != -1 ? ruleIndex : unchecked((int)(0xFFFF)));
                            data.Add(actionIndex != -1 ? actionIndex : unchecked((int)(0xFFFF)));
                            break;
                        }

                        case LexerActionType.Mode:
                        {
                            int mode = ((LexerModeAction)action).Mode;
                            data.Add(mode != -1 ? mode : unchecked((int)(0xFFFF)));
                            data.Add(0);
                            break;
                        }

                        case LexerActionType.More:
                        {
                            data.Add(0);
                            data.Add(0);
                            break;
                        }

                        case LexerActionType.PopMode:
                        {
                            data.Add(0);
                            data.Add(0);
                            break;
                        }

                        case LexerActionType.PushMode:
                        {
                            int mode = ((LexerPushModeAction)action).Mode;
                            data.Add(mode != -1 ? mode : unchecked((int)(0xFFFF)));
                            data.Add(0);
                            break;
                        }

                        case LexerActionType.Skip:
                        {
                            data.Add(0);
                            data.Add(0);
                            break;
                        }

                        case LexerActionType.Type:
                        {
                            int type = ((LexerTypeAction)action).Type;
                            data.Add(type != -1 ? type : unchecked((int)(0xFFFF)));
                            data.Add(0);
                            break;
                        }

                        default:
                        {
                            string message = string.Format(CultureInfo.CurrentCulture, "The specified lexer action type {0} is not valid.", action.ActionType);
                            throw new ArgumentException(message);
                        }
                    }
                }
            }
            // don't adjust the first value since that's the version number
            for (int i_4 = 1; i_4 < data.Count; i_4++)
            {
                if (data[i_4] < char.MinValue || data[i_4] > char.MaxValue)
                {
                    throw new NotSupportedException("Serialized ATN data element " + data[i_4] + " element " + i_4 + " out of range " + (int)char.MinValue + ".." + (int)char.MaxValue);
                }
                int value = (data[i_4] + 2) & unchecked((int)(0xFFFF));
                data[i_4] = value;
            }
            return data;
        }

        public virtual string Decode(char[] data)
        {
            data = (char[])data.Clone();
            // don't adjust the first value since that's the version number
            for (int i = 1; i < data.Length; i++)
            {
                data[i] = (char)(data[i] - 2);
            }
            StringBuilder buf = new StringBuilder();
            int p = 0;
            int version = ATNDeserializer.ToInt(data[p++]);
            if (version != ATNDeserializer.SerializedVersion)
            {
                string reason = string.Format("Could not deserialize ATN with version {0} (expected {1}).", version, ATNDeserializer.SerializedVersion);
                throw new InvalidOperationException(reason);
            }
            Guid uuid = ATNDeserializer.ToUUID(data, p);
            p += 8;
            if (!uuid.Equals(ATNDeserializer.SerializedUuid))
            {
                string reason = string.Format(CultureInfo.CurrentCulture, "Could not deserialize ATN with UUID {0} (expected {1}).", uuid, ATNDeserializer.SerializedUuid);
                throw new InvalidOperationException(reason);
            }
            p++;
            // skip grammarType
            int maxType = ATNDeserializer.ToInt(data[p++]);
            buf.Append("max type ").Append(maxType).Append("\n");
            int nstates = ATNDeserializer.ToInt(data[p++]);
            for (int i_1 = 0; i_1 < nstates; i_1++)
            {
                StateType stype = (StateType)ATNDeserializer.ToInt(data[p++]);
                if (stype == StateType.InvalidType)
                {
                    continue;
                }
                // ignore bad type of states
                int ruleIndex = ATNDeserializer.ToInt(data[p++]);
                if (ruleIndex == char.MaxValue)
                {
                    ruleIndex = -1;
                }
                string arg = string.Empty;
                if (stype == StateType.LoopEnd)
                {
                    int loopBackStateNumber = ATNDeserializer.ToInt(data[p++]);
                    arg = " " + loopBackStateNumber;
                }
                else
                {
                    if (stype == StateType.PlusBlockStart || stype == StateType.StarBlockStart || stype == StateType.BlockStart)
                    {
                        int endStateNumber = ATNDeserializer.ToInt(data[p++]);
                        arg = " " + endStateNumber;
                    }
                }
                buf.Append(i_1).Append(":").Append(ATNState.serializationNames[(int)(stype)]).Append(" ").Append(ruleIndex).Append(arg).Append("\n");
            }
            // this code is meant to model the form of ATNDeserializer.deserialize,
            // since both need to be updated together whenever a change is made to
            // the serialization format. The "dead" code is only used in debugging
            // and testing scenarios, so the form you see here was kept for
            // improved maintainability.
            // start
            int numNonGreedyStates = ATNDeserializer.ToInt(data[p++]);
            for (int i_2 = 0; i_2 < numNonGreedyStates; i_2++)
            {
                int stateNumber = ATNDeserializer.ToInt(data[p++]);
            }
            int numSllStates = ATNDeserializer.ToInt(data[p++]);
            for (int i_3 = 0; i_3 < numSllStates; i_3++)
            {
                int stateNumber = ATNDeserializer.ToInt(data[p++]);
            }
            int numPrecedenceStates = ATNDeserializer.ToInt(data[p++]);
            for (int i_4 = 0; i_4 < numPrecedenceStates; i_4++)
            {
                int stateNumber = ATNDeserializer.ToInt(data[p++]);
            }
            // finish
            int nrules = ATNDeserializer.ToInt(data[p++]);
            for (int i_5 = 0; i_5 < nrules; i_5++)
            {
                int s = ATNDeserializer.ToInt(data[p++]);
                bool leftFactored = ATNDeserializer.ToInt(data[p++]) != 0;
                if (atn.grammarType == ATNType.Lexer)
                {
                    int arg1 = ATNDeserializer.ToInt(data[p++]);
                    buf.Append("rule ").Append(i_5).Append(":").Append(s).Append(" ").Append(arg1).Append('\n');
                }
                else
                {
                    buf.Append("rule ").Append(i_5).Append(":").Append(s).Append('\n');
                }
            }
            int nmodes = ATNDeserializer.ToInt(data[p++]);
            for (int i_6 = 0; i_6 < nmodes; i_6++)
            {
                int s = ATNDeserializer.ToInt(data[p++]);
                buf.Append("mode ").Append(i_6).Append(":").Append(s).Append('\n');
            }
            int nsets = ATNDeserializer.ToInt(data[p++]);
            for (int i_7 = 0; i_7 < nsets; i_7++)
            {
                int nintervals = ATNDeserializer.ToInt(data[p++]);
                buf.Append(i_7).Append(":");
                bool containsEof = data[p++] != 0;
                if (containsEof)
                {
                    buf.Append(GetTokenName(TokenConstants.Eof));
                }
                for (int j = 0; j < nintervals; j++)
                {
                    if (containsEof || j > 0)
                    {
                        buf.Append(", ");
                    }
                    buf.Append(GetTokenName(ATNDeserializer.ToInt(data[p]))).Append("..").Append(GetTokenName(ATNDeserializer.ToInt(data[p + 1])));
                    p += 2;
                }
                buf.Append("\n");
            }
            int nedges = ATNDeserializer.ToInt(data[p++]);
            for (int i_8 = 0; i_8 < nedges; i_8++)
            {
                int src = ATNDeserializer.ToInt(data[p]);
                int trg = ATNDeserializer.ToInt(data[p + 1]);
                int ttype = ATNDeserializer.ToInt(data[p + 2]);
                int arg1 = ATNDeserializer.ToInt(data[p + 3]);
                int arg2 = ATNDeserializer.ToInt(data[p + 4]);
                int arg3 = ATNDeserializer.ToInt(data[p + 5]);
                buf.Append(src).Append("->").Append(trg).Append(" ").Append(Transition.serializationNames[ttype]).Append(" ").Append(arg1).Append(",").Append(arg2).Append(",").Append(arg3).Append("\n");
                p += 6;
            }
            int ndecisions = ATNDeserializer.ToInt(data[p++]);
            for (int i_9 = 0; i_9 < ndecisions; i_9++)
            {
                int s = ATNDeserializer.ToInt(data[p++]);
                buf.Append(i_9).Append(":").Append(s).Append("\n");
            }
            if (atn.grammarType == ATNType.Lexer)
            {
                // this code is meant to model the form of ATNDeserializer.deserialize,
                // since both need to be updated together whenever a change is made to
                // the serialization format. The "dead" code is only used in debugging
                // and testing scenarios, so the form you see here was kept for
                // improved maintainability.
                int lexerActionCount = ATNDeserializer.ToInt(data[p++]);
                for (int i_10 = 0; i_10 < lexerActionCount; i_10++)
                {
                    LexerActionType actionType = (LexerActionType)ATNDeserializer.ToInt(data[p++]);
                    int data1 = ATNDeserializer.ToInt(data[p++]);
                    int data2 = ATNDeserializer.ToInt(data[p++]);
                }
            }
            return buf.ToString();
        }

        public virtual string GetTokenName(int t)
        {
            if (t == -1)
            {
                return "EOF";
            }
            if (atn.grammarType == ATNType.Lexer && t >= char.MinValue && t <= char.MaxValue)
            {
                switch (t)
                {
                    case '\n':
                    {
                        return "'\\n'";
                    }

                    case '\r':
                    {
                        return "'\\r'";
                    }

                    case '\t':
                    {
                        return "'\\t'";
                    }

                    case '\b':
                    {
                        return "'\\b'";
                    }

                    case '\f':
                    {
                        return "'\\f'";
                    }

                    case '\\':
                    {
                        return "'\\\\'";
                    }

                    case '\'':
                    {
                        return "'\\''";
                    }

                    default:
                    {
                        if (t >= 0x20 && t <= 0x7f)
                        {
                            return '\'' + char.ToString((char)t) + '\'';
                        }
                        // convert to a 4-digit hex string
                        string hex = t.ToString("X4");
                        string unicodeStr = "'\\u" + hex + "'";
                        return unicodeStr;
                    }
                }
            }
            if (tokenNames != null && t >= 0 && t < tokenNames.Count)
            {
                return tokenNames[t];
            }
            return t.ToString();
        }

        /// <summary>Used by Java target to encode short/int array as chars in string.</summary>
        public static string GetSerializedAsString(ATN atn, IList<string> ruleNames)
        {
            return new string(GetSerializedAsChars(atn, ruleNames));
        }

        public static List<int> GetSerialized(ATN atn, IList<string> ruleNames)
        {
            return new Antlr4.Runtime.Atn.ATNSerializer(atn, ruleNames).Serialize();
        }

        public static char[] GetSerializedAsChars(ATN atn, IList<string> ruleNames)
        {
            return Utils.ToCharArray(GetSerialized(atn, ruleNames));
        }

        public static string GetDecoded(ATN atn, IList<string> ruleNames, IList<string> tokenNames)
        {
            List<int> serialized = GetSerialized(atn, ruleNames);
            char[] data = Utils.ToCharArray(serialized);
            return new Antlr4.Runtime.Atn.ATNSerializer(atn, ruleNames, tokenNames).Decode(data);
        }

        private void SerializeUUID(List<int> data, Guid uuid)
        {
            byte[] uuidData = uuid.ToByteArray();
            data.Add((uuidData[14] << 8) + uuidData[15]);
            data.Add((uuidData[12] << 8) + uuidData[13]);
            data.Add((uuidData[10] << 8) + uuidData[11]);
            data.Add((uuidData[8] << 8) + uuidData[9]);
            data.Add(BitConverter.ToInt16(uuidData, 6));
            data.Add(BitConverter.ToInt16(uuidData, 4));
            SerializeInt(data, BitConverter.ToInt32(uuidData, 0));
        }

        private void SerializeInt(List<int> data, int value)
        {
            data.Add((char)value);
            data.Add((char)(value >> 16));
        }
    }
}
